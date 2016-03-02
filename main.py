from cachier import Cachier
import sys
from time import sleep

if __name__ == '__main__':
    print 'please input item file path and discount file path seperated by spaces'
    item_file, discount_file = raw_input().split()
    c = Cachier(item_file, discount_file)
    print 'Loaded item info and discount info successfully'
    print "-----------------available items--------"
    print c.items
    print "-----------------available discount--------"
    print c.discount
    while 1:
        try:
            print 'input bill list, like ["ITEM000001", "ITEM000005"]'
            jsondata = raw_input()
            c.get_detailed_bill(jsondata)
        except KeyboardInterrupt, e:
            print 'system is being shutdown'
            sleep(2)
            sys.exit('bye')
        except:
            print 'input error'

