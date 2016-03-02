{-# LANGUAGE ScopedTypeVariables #-}
import Cashier
import Control.Exception(handle,SomeException)
import Control.Monad (forever)
import qualified Data.Map as M
main = do
        putStrLn "please input item file path and discount file path seperate by a space"
        [itemsFile, discountFile] <- fmap words getLine
        items <- getItemInfo itemsFile
        discount <- getDiscountInfo discountFile

        putStrLn "\nLoaded item info and discount info successfully\n"
        putStrLn "-----------all available items-------------"
        print items
        putStrLn "-----------all avaiable discount-----------"
        print discount

        putStrLn "\n"
        
        forever $ do
            putStrLn "please input bill list, like [\"ITEM000005\", \"ITEM000003-6.6\"]"
            jsondata <- getLine
            handle (\(e::SomeException) -> putStrLn "input error")  (putStrLn $ getDetailedBill jsondata  discount items)
            putStrLn"\n\n"
