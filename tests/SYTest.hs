module Main where

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.HUnit
import Test.QuickCheck
import ForSyDe
import ForSyDe.Core.Signal
import ForSyDe.Core.ValueExt
import qualified ForSyDe.MoCLib.SY as SY


import Data.List (intersperse)





unsplit :: Char -> [String] -> String
unsplit c = concat . intersperse [c]

-- show
split :: Char -> String -> [String]
split c xs = xs' : if null xs'' then [] else split c (tail xs'')
    where xs' = takeWhile (/=c) xs
          xs''= dropWhile (/=c) xs

prop_split_inv xs = forAll (elements xs) $ \c -> unsplit c (split c xs) == xs

   
testfoo = TestCase $ assertEqual "Foo == Foo"
    "Foo" "Foo"

testfoo2 = TestCase $ assertEqual "Foo != Bar"
    "Foo" "Bar"

-- hUnitTestToTests: Adapt an existing HUnit test into a list of test-framework tests
tests = hUnitTestToTests $ TestList [TestLabel "testfoo" testfoo,
                                     TestLabel "testfoo2" testfoo2]



-- fromSY (SY.SY a) = a

-- instance Arbitrary (Signal a) where
--   arbitrary = do
--     x <- arbitrary
--     return (signal x)

-- instance Arbitrary (SY.SY a) where
--   arbitrary = do
--     x <- arbitrary
--     return (SY.SY x)


-- instance Arbitrary (Value a) where
--   arbitrary = do
--     x <- arbitrary
--     return (value x)


-- sync_comb :: SY.Sig Int -> SY.Sig Int -> Bool 
-- sync_comb sa sb = SY.comb21 (+) sa sb == signal ( map SY.SY $ zipWith (psi21 (+)) (map fromSY (fromSignal sa)) (map fromSY (fromSignal sb)))

main = do
  a <- quickCheck prop_split_inv
  defaultMain tests
-- /show
