
class DPT_Error(Exception):
    """
    """

class DPT(object):
    """ Datapoint Type hanlding class

    Manage Datapoint Type informations and behavior.

    @ivar _id: Datapoint Type ID
    @type _id: L{DPTID}

    @ivar _desc: description of the DPT
    @type _desc: str

    @ivar _limits: value limits the DPT can handle
    @type _limits: tuple of int/float/str

    @ivar _unit: optional unit of the DPT
    @type _unit: str
    """
    def __init__(self, dptId, desc, limits=None, unit=None):
        """ Init the DPT object

        @param dptId: available implemented Datapoint Type ID
        @type dptId: L{DPTID} or str

        @param desc: description of the DPT
        @type desc: str

        @param limits: value limits the DPT can handle
        @type limits: tuple of int/float/str

        @param unit: optional unit of the DPT
        @type unit: str

        @raise DPTValueError:
        """

        self._id = dptId
        self._desc = desc
        if limits is not None:
            self._limits = tuple(limits)
        self._unit = unit

    def __str__(self):
        return "<DPT('%s\)>" % self._id

    @property
    def id(self):
        """ return the DPT ID
        """
        return self._id

    @property
    def desc(self):
        """ return the DPT description
        """
        return self._desc

    @property
    def limits(self):
        """ return the DPT limits
        """
        return self._limits

    @property
    def unit(self):
        """ return the DPT unit
        """
        return self._unit
    
    def decode(self, data):
        """ Conversion from KNX encoded data to python value

        @param data: KNX encoded data
        @type data: int

        @return: python value
        @rtype: depends on the DPT
        """
        raise NotImplementedError

    def encode(self, value):
        """ Conversion from python value to KNX encoded data

        @param value: python value
        @type value: depends on the DPT
        """
        raise NotImplementedError
    
    def isRRDSupported(self):
        """ Whether this dpt value can be stored to 
            a round robin database. If a sub class returns true 
            toRRDValue needs to be implemented too!
        """
        return False
    
    def toRRDValue(self, value):
        """ Conversion from python value to RRD data
        
        @param value: python value
        @type value: int
        """
        raise NotImplementedError


class DPT_Boolean(DPT):
    """ DPT subclass for 1-Bit (B1) KNX Datapoint Type

     - 1 Byte: 00000000B
     - B: Binary [0, 1]

    .
    """
    
    def __init__(self, dptId, desc, limits=None, unit=None):
        DPT.__init__(self, dptId, desc, limits, unit)

    def decode(self, data):
        self.checkData(data)
        return self._limits[data]

    def encode(self, value):
        self.checkValue(value)
        return self._limits.index(value)
    
    def checkData(self, data):
        if data not in (0x00, 0x01):
            try:
                raise DPT_Error("data %s not in (0x00, 0x01)" % hex(data))
            except TypeError:
                raise DPT_Error("data not in (0x00, 0x01)")

    def checkValue(self, value):
        if value not in self._dpt.limits and value not in self.DPT_Generic.limits:
            raise DPT_Error("value %s not in %s" % (value, str(self._dpt.limits)))


class DPT_3BitControl(DPT):
    """ DPT subclass for 3-Bit-Control (B1U3) KNX Datapoint Type

    This is a composite DPT.

     - 1 Byte: 0000CSSSS
     - C: Control bit [0, 1]
     - S: StepCode [0:7]

    The _data param of this DPT only handles the stepCode; the control bit is handled by the sub-DPT.

    @todo: create and use a DPTCompositeConverterBase?

    @ivar _dpt: sub-DPT
    @type _dpt: L{DPT}
    """

    def __init__(self, dptId, desc, limits=None, unit=None):
        DPT.__init__(self, dptId, desc, limits, unit)

#         dptId_ = "1.%s" % dptId.sub
#         self._dpt2 = DPT_Boolean(dptId_)

    def checkData(self, data):
        if not 0x00 <= data <= 0x0f:
            raise DPT_Error("data %s not in (0x00, 0x0f)" % hex(data))

    def checkValue(self, value):
        if not self._dpt.limits[0] <= value <= self._dpt.limits[1]:
            raise DPT_Error("value %d not in range %r" % (value, repr(self._dpt.limits)))

    def decode(self, data):
        ctrl = (data & 0x08) >> 3
        stepCode = data & 0x07
        value = stepCode if ctrl else -stepCode
        return value

    def encode(self, value):
        ctrl = 1 if value > 0 else 0
        stepCode = abs(value) & 0x07
        data = ctrl << 3 | stepCode
        return data


dpt_1_000 = DPT_Boolean("1.000", "Generic", (0, 1))
dpt_1_001 = DPT_Boolean("1.001", "Switch", ("Off", "On"))
dpt_1_002 = DPT_Boolean("1.002", "Boolean", (False, True))
dpt_1_003 = DPT_Boolean("1.003", "Enable", ("Disable", "Enable"))
dpt_1_004 = DPT_Boolean("1.004", "Ramp", ("No ramp", "Ramp"))
dpt_1_005 = DPT_Boolean("1.005", "Alarm", ("No alarm", "Alarm"))
dpt_1_006 = DPT_Boolean("1.006", "Binary value", ("Low", "High"))
dpt_1_007 = DPT_Boolean("1.007", "Step", ("Decrease", "Increase"))
dpt_1_008 = DPT_Boolean("1.008", "Up/Down", ("Up", "Down"))
dpt_1_009 = DPT_Boolean("1.009", "Open/Close", ("Open", "Close"))
dpt_1_010 = DPT_Boolean("1.010", "Start", ("Stop", "Start"))
dpt_1_011 = DPT_Boolean("1.011", "State", ("Inactive", "Active"))
dpt_1_012 = DPT_Boolean("1.012", "Invert", ("Not inverted", "Inverted"))
dpt_1_013 = DPT_Boolean("1.013", "Dimmer send-style", ("Start/stop", "Cyclically"))
dpt_1_014 = DPT_Boolean("1.014", "Input source", ("Fixed", "Calculated"))
dpt_1_015 = DPT_Boolean("1.015", "Reset", ("No action", "Reset"))
dpt_1_016 = DPT_Boolean("1.016", "Acknowledge", ("No action", "Acknowledge"))
dpt_1_017 = DPT_Boolean("1.017", "Trigger", ("Trigger", "Trigger"))
dpt_1_018 = DPT_Boolean("1.018", "Occupancy", ("Not occupied", "Occupied"))
dpt_1_019 = DPT_Boolean("1.019", "Window/Door", ("Closed", "Open"))
dpt_1_021 = DPT_Boolean("1.021", "Logical function", ("OR", "AND"))
dpt_1_022 = DPT_Boolean("1.022", "Scene A/B", ("Scene A", "Scene B"))
dpt_1_023 = DPT_Boolean("1.023", "Shutter/Blinds mode", ("Only move Up/Down", "Move Up/Down + StepStop"))

dpt_3_000 = DPT_3BitControl("3.000", "Generic", (-7, 7))
dpt_3_007 = DPT_3BitControl("3.007", "Dimming", (-7, 7))
dpt_3_008 = DPT_3BitControl("3.008", "Blinds", (-7, 7))
