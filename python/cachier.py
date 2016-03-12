# -*- coding: utf-8 -*- 
EPS = 1e-6
class Cachier:
    def __init__(self, item_file, discount_file):
        self.items = self.get_items(item_file)
        self.discount = self.get_discount(discount_file)

    def get_items(self, item_file):
        items = dict()
        with open(item_file) as f:
            for lines in f.readlines()[1:]:
                barcode,name,unit,price = lines.split()[1:5]
                items[barcode] = ItemInfo(name, unit, price)
        return items

    def get_discount(self, discount_file):
        discount = dict()
        with open(discount_file) as f:
            for lines in f.readlines():
                barcode, type = lines.split()
                # two-for-one discount has higher priority
                if discount.get(barcode, None) != '21':
                    discount[barcode] = type
        return discount

    # sum quantity group by barcode
    def summary(self, jsondata):
        from json import loads
        from itertools import groupby

        # weight can be double or int
        def parse(item):
            if '-' not in item:
                return (item, 1)
            barcode, quantity = item.split('-')
            castfunc = float if '.' in quantity  else int
            return (barcode, castfunc(quantity))

        data = map(parse, sorted(loads(jsondata)))
        smr = [(x,sum((k[1] for k in list(y)))) for x, y in groupby(data, key = lambda x : x[0])]

        return smr


    def get_detailed_bill(self, jsondata):
        total = save = 0.0
        two_for_one_info = ""
        separate = "----------------------"

        smr = self.summary(jsondata)
        print '***<没钱赚商店>购物清单***'
        for barcode, quantity in smr:
            iteminfo = self.items[barcode]
            name, unit, price = iteminfo.name, iteminfo.unit, iteminfo.price
            this_total = price * quantity
            discount_info = self.discount.get(barcode, None)
            if discount_info == None:
                is95 = this_save = 0
            elif discount_info == "95":
                is95, this_save = 1, 0.05 * this_total
            else:
                x = int((quantity + EPS) / 3)
                if x:
                    two_for_one_info += "名称：%s，数量：%d%s\n" % (name, x, unit)
                is95 = this_save = 0

            total += this_total
            save += this_save
            this_info = "名称：%s，数量：%s%s，单价：%.2f(元)，小计：%.2f(元)" % (name, quantity, unit, price, this_total - this_save)
            if is95:
                this_info += "，节省%.2f(元)"  % this_save
            print this_info

        print separate

        if two_for_one_info:
            print "买二赠一商品："
            print  two_for_one_info,
            print separate

        print "总计：%.2f(元)" % (total - save)

        if save > EPS:
            print "节省：%.2f(元)" %  save

        print "**********************"


class ItemInfo:
    def __init__(self, name, unit, price):
        self.price = float(price)
        self.name = name
        self.unit = unit


