import Cashier
import qualified Data.Map as M

main = do
        items <- getItemInfo "items"
        discount <- getDiscountInfo "discount"

        let jsondata = "[\"ITEM000001\", \"ITEM000001\", \"ITEM000001\", \"ITEM000001\", \"ITEM000001\", \"ITEM000003-2\", \"ITEM000005\", \"ITEM000005\", \"ITEM000005\"]"


        let discount = M.fromList [("ITEM000005", "21"), ("ITEM000001", "21")]
        putStrLn $  getDetailedBill jsondata discount items
        putStrLn "\n"

        let discount = M.fromList []
        putStrLn $  getDetailedBill jsondata discount items
        putStrLn "\n"

        let discount = M.fromList [("ITEM000003", "95")]
        putStrLn $  getDetailedBill jsondata discount items
        putStrLn "\n"

        let discount = M.fromList [("ITEM000003", "95"),("ITEM000005", "21"), ("ITEM000001", "21")]
        putStrLn $  getDetailedBill jsondata discount items
        putStrLn "\n"
