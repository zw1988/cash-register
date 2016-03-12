from cachier import Cachier

jsondata = "[\"ITEM000001\", \"ITEM000001\", \"ITEM000001\", \"ITEM000001\", \"ITEM000001\", \"ITEM000003-2\", \"ITEM000005\",     \"ITEM000005\", \"ITEM000005\"]"


c = Cachier("../items", "../discount")

discount = dict(ITEM000005 = "21",  ITEM000001 = "21")
c.discount = discount
c.get_detailed_bill(jsondata)
print

discount = dict()
c.discount = discount
c.get_detailed_bill(jsondata)
print

discount = dict(ITEM000003 = "95")
c.discount = discount
c.get_detailed_bill(jsondata)
print

discount = dict(ITEM000003 = "95", ITEM000005 = "21", ITEM000001 = "21")
c.discount = discount
c.get_detailed_bill(jsondata)
print
