module Cashier(
    getItemInfo,
    getDiscountInfo,
    getDetailedBill
)where
import qualified Data.Map as M
import qualified Data.List as L
import Text.Printf (printf)

type Barcode = String
type Discount = String

eps = 0.000001 :: Double

data ItemInfo = ItemInfo {
            getPrice       :: Double,
            getUnit        :: String,
            getName        :: String,
            getcategory    :: String -- getcategory is not used
        }deriving (Show)


parseOneItem  :: String -> (Barcode, ItemInfo)
parseOneItem  bs = 
        let info = words bs
            [barcode, name, unit, price, category] = tail info
            iteminfo = ItemInfo {
                                    getName = name,
                                    getUnit = unit,
                                    getPrice = read price, -- cast string to double
                                    getcategory = category -- not used
                                }
        in (barcode, iteminfo)

--read all items info from a file and keep them in a map 
getItemInfo :: FilePath -> IO (M.Map Barcode ItemInfo)
getItemInfo path = do
        contents <- readFile path
        return $ M.fromList . map  parseOneItem . tail $ lines contents

--如果物品重量有小数点，则用Weight Double
data Quantity = Number Int | Weight Double
                deriving (Show)


add (Number a)  (Number b) = Number (a+b)
add (Weight a)  (Weight b) = Weight (a+b)
-- weight can be int and double, any Weight Double will make sum of
-- weight a double value
add (Number a)  (Weight b) = Weight ((fromIntegral a) + b)
add (Weight a)  (Number b) = Weight ((fromIntegral b) + a)


--sort item list,  sum quantity group by barcode
summary :: String -> [(Barcode, Quantity)]
summary jsondata = 
        let 
            bills = L.sort $ read jsondata :: [String]
            
            parseOne :: String -> (Barcode, Quantity)
            parseOne s = case L.elem '-' s of 
                                True  -> let (barcode, weight) = L.break (=='-') s 
                                         in  case L.elem '.' weight of 
                                                    --if no '.' in weight
                                                    --use Number Int
                                                    True -> (barcode, Weight . read $ tail weight)
                                                    False -> (barcode, Number . read $ tail weight)
                                False -> (s, Number 1)

            go :: [String] -> (Barcode, Quantity) -> [(Barcode, Quantity)]
            go bills last@(lastbar, lastquan)
                | null bills = [last]
                | otherwise   =  let (x : xs) = bills
                                     (barcode, quantity) = parseOne x
                                in if barcode == lastbar then go xs (barcode, add lastquan quantity) else last : go xs (barcode, quantity)


        in go  (tail bills) (parseOne $ head bills)
        
--Read all discount info from a file. If an item has both "21"(three for
--two) and "95" (95% discount), it will keep "21" and discard "95"
getDiscountInfo :: FilePath -> IO (M.Map Barcode Discount)
getDiscountInfo path =  do
        contents <- readFile path
        let discount =  map words . lines $ contents 
            -- if new discount is "21"(three for two), then replace the old discount
            update key new old = if new == "21" then new else old
        return $ foldr (\[barcode, new] -> M.insertWithKey update barcode new) M.empty discount


getDetailedBill jsondata discountMap itemsMap = "***<没钱赚商店>购物清单***\n" ++ loop smr "" 0.0 0.0
        where 
            smr = summary jsondata
            sumOne price (Number a) = (fromIntegral a) * price
            sumOne price (Weight a) = a * price
            showQuantity (Number a) = show a
            showQuantity (Weight a) = show a
            
            loop :: [(Barcode, Quantity)] -> String -> Double -> Double -> String
            loop smr twoForOne total save 
                | null smr = 
                    let separate = "----------------------\n"
                        twoForOneInfo = if null twoForOne then "" else "买二赠一商品:\n" ++ twoForOne ++ separate
                        totalInfo = printf "总计：%.2f(元)\n" (total-save)
                        saveInfo = if save < eps then "" else "节省：" ++ (printf "%.2f" save) ++ "(元)\n"
                    in separate ++ twoForOneInfo ++ totalInfo ++ saveInfo ++ "**********************"
                | otherwise =  let  (barcode, quantity) : xs = smr
                                    Just iteminfo = M.lookup barcode itemsMap
                                    price = getPrice iteminfo
                                    unit = getUnit iteminfo
                                    name = getName iteminfo
                                    thisTotal= sumOne price quantity
                                    discountInfo = M.lookup barcode discountMap
                                    (thisTwoForOne, is95, thisSave) = case  discountInfo of
                                          Nothing -> ("", False, 0.0)
                                          Just "95" -> ("", True,  0.05 * thisTotal)
                                          _  -> let  x = div (case quantity of  
                                                             Number a -> a 
                                                             Weight a -> truncate (a + eps)) 3
                                                in (if x > 0 then "名称: " ++ name ++ ", 数量: " ++ show x ++ unit ++ "\n" else "", False, price * (fromIntegral x))
                                    thisInfo = (printf "名称：%s，数量：%s%s，单价：%.2f(元)，小计：%.2f(元)" name (showQuantity quantity) unit price (thisTotal - thisSave)) ++ (if is95 then (printf ", 节省: %.2f(元)" thisSave) else "") ++ "\n"
                            in thisInfo ++ loop xs (twoForOne ++ thisTwoForOne) (total + thisTotal) (save + thisSave)

