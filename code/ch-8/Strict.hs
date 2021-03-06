{-# LANGUAGE BangPatterns #-}

module Strict where

import Data.List

sum' :: Num a => [a] -> a
sum' = iter 0 
    where iter res []        = res
          iter res (a:as)    = let res' = a + res
                               in  res' `seq` iter res' as 

product' :: Num a => [a] -> a
product' = iter 1
    where iter res []        = res
          iter res (a:as)    = let res' = a * res
                               in  seq res' $ iter res' as 


data Strict a = Strict !a
data Lazy   a = Lazy a

data TheDouble = TheDouble !Double
    deriving (Show, Eq)

instance Num TheDouble where
    (+) = inTheDouble2 (+)
    (-) = inTheDouble2 (-)
    (*) = inTheDouble2 (*)

    abs = inTheDouble1 abs
    signum = inTheDouble1 signum
    fromInteger = TheDouble . fromInteger

inTheDouble1 f  (TheDouble a)                = TheDouble $ f a
inTheDouble2 op (TheDouble a) (TheDouble b)  = TheDouble $ op a b


mean :: [Double] -> Double
mean = division . foldl' count (0, 0)
    where count  (sum, leng) a = (sum+a, leng+1)
          division (sum, leng) = sum / fromIntegral leng


mean' :: [Double] -> Double
mean' = division . iter (0, 0)
    where iter res          []      = res
          iter (sum, leng)  (a:as)  = 
                let s = sum  + a
                    l = leng + 1
                in  s `seq` l `seq` iter (s, l) as
          
          division (sum, leng) = sum / fromIntegral leng


mean'' :: [Double] -> Double
mean'' = division . foldl' iter (0, 0)
    where iter (!sum, !leng) a = (sum  + a, leng + 1)
          division (sum, leng) = sum / fromIntegral leng


constBang :: a -> b -> a
constBang a !b = a

{-

lazySafeHead :: [a] -> Maybe a
lazySafeHead ~(x:xs) = Just x
lazySafeHead []      = Nothing

-}


lazySafeHead :: [a] -> Maybe a
lazySafeHead []      = Nothing
lazySafeHead ~(x:xs) = Just x
