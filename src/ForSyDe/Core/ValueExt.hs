-----------------------------------------------------------------------------
-- |
-- Module      :  ForSyDe.Core.AbsentExt
-- Copyright   :  (c) George Ungureanu, KTH/ICT/ESY 2016;
-- License     :  BSD-style (see the file LICENSE)
-- 
-- Maintainer  :  forsyde-dev@ict.kth.se
-- Stability   :  experimental
-- Portability :  portable
--
-- This module implements the atoms and wrappers for the behavior
-- layer in ForSyDe processes.
-----------------------------------------------------------------------------
module ForSyDe.Core.ValueExt(

  -- | The behavior layer is enabled by the 'Value' type constructor.
  
  Value(..),

  -- * Utility functions

  -- | These functions are provided for user convenience

  value, fromValue, unsafeFromValue, isPresent, isAbsent, isUndefined,

  -- * Behavior atoms

  -- | These are the primitive (undivisible) blocks for implementing
  -- behavior wrappers. Each atom has a distinct behavioural semantic
  -- which reflects a real (analizable, implementable) behavior.
  
  (>$), (>*), (>!), (>?), (>%),

  -- * Behavior wrappers
  
  -- ** @psi@
  
  -- | The @psi@/XY/ wrapper wraps a function with /X/ inputs and /Y/
  -- outputs in a default ForSyDe behavior. E.g.:
  --
  -- >>> let (v,u,a)=(Value 1, Undef, Abst)
  -- >>> (v,u,a)
  -- (1,?,⟂)
  -- >>> let f a b c = (a+b,b-c)
  -- >>> let wf = psi32 f
  -- >>> t: wf
  -- wf :: Num b => Value b -> Value b -> Value b -> (Value b, Value b)
  -- >>> wf v v v
  -- (2,0)
  -- >>> wf v u v
  -- (?,?)
  -- >>> wf v a v
  -- (*** Exception: Illegal occurrence of an absent and present event
  
  psi11, psi12, psi13, psi14, psi15, psi16, psi87, psi18,
  psi21, psi22, psi23, psi24, psi25, psi26, psi87, psi28,
  psi31, psi32, psi33, psi34, psi35, psi36, psi87, psi38,
  psi41, psi42, psi43, psi44, psi45, psi46, psi87, psi48,
  psi51, psi52, psi53, psi54, psi55, psi56, psi87, psi58,
  psi61, psi62, psi63, psi64, psi65, psi66, psi87, psi68,
  psi71, psi72, psi73, psi74, psi75, psi76, psi87, psi78,
  psi81, psi82, psi83, psi84, psi85, psi86, psi87, psi88,

  -- ** @store@

  -- | The @store@/X/ wrapper pushes the present and defined values
  -- into a given (e.g. FIFO) buffer.
  --
  -- >>> store5 (Value [1,2]) (Value 3) Undef (Value 4) Abst Undef
  -- [4,3,1,2]
  -- >>> store5 Undef         (Value 3) Undef (Value 4) Abst Undef
  -- ?
  -- >>> store5 Abst          (Value 3) Undef (Value 4) Abst Undef
  -- *** Exception: Illegal occurrence of an absent and present event
  
  store1, store2, store3, store4, store5, store6, store7, store8,
 
  ) where

import ForSyDe.Core.Utilities

-- |The data type 'Value' wraps arbtrary types to extend them with
-- tokens carrying special behavioural semantics, as defined by
-- ForSyDe
data Value a = Abst   -- ^ denotes an absent event
             | Undef  -- ^ denotes an undefined value
             | Value a -- ^ a wrapped "present" event with a "defined"
                       -- value
             deriving (Eq)

-- | Shows 'Abst' as \'&#8869;\', 'Undef' as \'?\' while a wrapped
-- value is represented with its value.
instance Show a => Show (Value a) where
 showsPrec _ x = showsValue x
   where showsValue Abst     = (++) "\10178"       
         showsValue Undef    = (++) "?"
         showsValue (Value x) = (++) (show x)

-- | Reads the \'_\' character to an 'Abst', a \'?\' to an 'Undef',
-- and a normal value to wrapped one.
instance Read a => Read (Value a) where
  readsPrec _ x       = readsValue x 
   where readsValue s = [(Abst, r1) | ("_", r1) <- lex s]
           ++ [(Undef, r2) | ("?", r2) <- lex s]
           ++ [(Value x, r3) | (x, r3) <- reads s]

-- | 'Functor' instance. Bypasses the special values and maps a
-- function to the wrapped value. Provides the @(\<$\>)@ operator.
instance Functor Value where
  fmap _ Abst      = Abst
  fmap _ Undef     = Undef
  fmap f (Value x) = Value (f x)

-- | 'Applicative' instance. Check source code for the lifting
-- rules. Provides the @(\<*\>)@ operator
instance Applicative Value where
  pure = Value 
  (Value x) <*> (Value y) = Value (x y)
  Undef     <*> (Value _) = Undef
  (Value _) <*> Undef     = Undef
  Undef     <*> Undef     = Undef
  Abst      <*> Abst      = Abst
  _         <*> _         = error "Illegal occurrence of an absent and present event"

-----------------------------------------------------------------------------
-- Behavioural implementations
-----------------------------------------------------------------------------

infixl 4 >$, >*, >! , >?,  >%
-- | The exact equivalent of the 'fmap' function or the '<$>' infix
-- operator for extended values. It bypasses the special values and
-- maps a function @f@ to a wrapped value. It may be regarded as the
-- "default behavior" of a process.
--
-- >>> let (a,u,v)=(Abst,Undef,Value 1)
-- >>> (a,u,v)
-- (⟂,?,1)
-- >>> let f = (+1)
-- >>> (f >$ a, f >$ u, f >$ v)
-- (⟂,?,2)
-- >>> (f <$> a, f <$> u, f <$> v)
-- (⟂,?,2)
--
-- As seen in the example above, '>$' is interchangeable with '<$>'.

(>$) :: (a -> b) -> Value a -> Value b
(>$) = fmap

-- | The exact equivalent of the applicative operator '<*>' for
-- extended values. It may be regarded as the default behavior in case
-- two events interact with each other. Check the source source code
-- for the Applicative instance to see the lifting rules.
--
-- >>> let (a,u,v)=(Abst,Undef,Value 1)
-- >>> (a,u,v)
-- (⟂,?,1)
-- >>> (Value (+1)) >* v
-- 2
-- >>> (Value (+1)) >* u
-- ?
-- >>> (Value (+1)) >* a
-- *** Exception: Illegal occurrence of an absent and present event
--
-- Things get interesting when we combine '>$' and '>*' in an
-- applicative style. As expected, below we get the same results:
-- 
-- >>> (+) >$ v >* v
-- 2
-- >>> (+) >$ v >* u
-- ?
-- >>> (+) >$ a >* v
-- *** Exception: Illegal occurrence of an absent and present event
--
-- As with '>$', '>*' is also interchangeable with '<*>'.
(>*) :: Value (a -> b) -> Value a -> Value b
(>*) = (<*>)

-- | Predicate atom which replaces a value with and absent event based
-- on a boolean.
--
-- >>> let p = map Value [True, True, False, False]
-- >>> zipWith (>!) p [Value 1, Undef, Value 2, Abst]
-- [1,?,⟂,⟂]
(>!) :: Value Bool  -- ^ wrapped boolean predicate
     -> Value a     -- ^ value to replace
     -> Value a     -- ^ result
p >! x = if p == Value True then x else Abst

-- | Predicate atom which replaces a value with undefined based on a
-- boolean. The 'Abst' event persists.
--
-- >>> let p = map Value [True, True, False, False]
-- >>> zipWith (>?) p [Value 1, Undef, Value 2, Abst]
-- [1,?,?,⟂]
(>?) :: Value Bool  -- ^ wrapped boolean predicate
      -> Value a     -- ^ value to replace
      -> Value a     -- ^ result
p >? Abst = Abst
p >? x    = if p == Value True then x else Undef

-- | serial storage atom. Stores only present values
--
-- >>> Value [] >% Value 1 >% Undef >% Value 2 >% Abst
-- [2,1]
(>%) :: Value [a]  -- ^ input storing buffer wrapped as value
      -> Value a   -- ^ value to be stored
      -> Value [a] -- ^ output buffer
buff >% Abst   = buff
buff >% Undef  = buff
buff >% Value a = (:) <$> Value a <*> buff

-----------------------------------------------------------------------------
-- Utility functions
-----------------------------------------------------------------------------

-- |The function 'fromValue' converts a value from a extended value.
fromValue         :: a -> Value a -> a
-- |The function 'fromValue' converts a value from a extended value.
unsafeFromValue   ::  Value a -> a
-- |The functions 'isPresent' checks for the presence of a value.
isPresent         :: Value a -> Bool
-- |The functions 'isAbsent' checks for the absence of a value.
isAbsent          :: Value a -> Bool
-- |The functions 'isUndefined' checks if the value is defined.
isUndefined       :: Value a -> Bool
-- | The function 'abstExt' converts a usual value to a present value. 
value           :: a -> Value a  

value                    = pure
fromValue x Abst         = x   
fromValue _ (Value y)     = y
unsafeFromValue (Value y) = y
unsafeFromValue Abst     = error "Should not be absent or undefined"
isAbsent Abst            = True
isAbsent _               = False
isUndefined Undef        = True
isUndefined _            = False
isPresent (Value _)       = True
isPresent _              = False


-----------------------------------------------------------------------------
-- Behavior wrappers
-----------------------------------------------------------------------------

psi11 f a1                      =         (f >$ a1)
psi12 f a1                      = funzip2 (f >$ a1)
psi13 f a1                      = funzip3 (f >$ a1)
psi14 f a1                      = funzip4 (f >$ a1)
psi15 f a1                      = funzip5 (f >$ a1)
psi16 f a1                      = funzip6 (f >$ a1)
psi17 f a1                      = funzip7 (f >$ a1)
psi18 f a1                      = funzip8 (f >$ a1)
psi21 f a1 a2                   =         (f >$ a1 >* a2)
psi22 f a1 a2                   = funzip2 (f >$ a1 >* a2)
psi23 f a1 a2                   = funzip3 (f >$ a1 >* a2)
psi24 f a1 a2                   = funzip4 (f >$ a1 >* a2)
psi25 f a1 a2                   = funzip5 (f >$ a1 >* a2)
psi26 f a1 a2                   = funzip6 (f >$ a1 >* a2)
psi27 f a1 a2                   = funzip7 (f >$ a1 >* a2)
psi28 f a1 a2                   = funzip8 (f >$ a1 >* a2)
psi31 f a1 a2 a3                =         (f >$ a1 >* a2 >* a3)
psi32 f a1 a2 a3                = funzip2 (f >$ a1 >* a2 >* a3)
psi33 f a1 a2 a3                = funzip3 (f >$ a1 >* a2 >* a3)
psi34 f a1 a2 a3                = funzip4 (f >$ a1 >* a2 >* a3)
psi35 f a1 a2 a3                = funzip5 (f >$ a1 >* a2 >* a3)
psi36 f a1 a2 a3                = funzip6 (f >$ a1 >* a2 >* a3)
psi37 f a1 a2 a3                = funzip7 (f >$ a1 >* a2 >* a3)
psi38 f a1 a2 a3                = funzip8 (f >$ a1 >* a2 >* a3)
psi41 f a1 a2 a3 a4             =         (f >$ a1 >* a2 >* a3 >* a4)
psi42 f a1 a2 a3 a4             = funzip2 (f >$ a1 >* a2 >* a3 >* a4)
psi43 f a1 a2 a3 a4             = funzip3 (f >$ a1 >* a2 >* a3 >* a4)
psi44 f a1 a2 a3 a4             = funzip4 (f >$ a1 >* a2 >* a3 >* a4)
psi45 f a1 a2 a3 a4             = funzip5 (f >$ a1 >* a2 >* a3 >* a4)
psi46 f a1 a2 a3 a4             = funzip6 (f >$ a1 >* a2 >* a3 >* a4)
psi47 f a1 a2 a3 a4             = funzip7 (f >$ a1 >* a2 >* a3 >* a4)
psi48 f a1 a2 a3 a4             = funzip8 (f >$ a1 >* a2 >* a3 >* a4)
psi51 f a1 a2 a3 a4 a5          =         (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi52 f a1 a2 a3 a4 a5          = funzip2 (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi53 f a1 a2 a3 a4 a5          = funzip3 (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi54 f a1 a2 a3 a4 a5          = funzip4 (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi55 f a1 a2 a3 a4 a5          = funzip5 (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi56 f a1 a2 a3 a4 a5          = funzip6 (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi57 f a1 a2 a3 a4 a5          = funzip7 (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi58 f a1 a2 a3 a4 a5          = funzip8 (f >$ a1 >* a2 >* a3 >* a4 >* a5)
psi61 f a1 a2 a3 a4 a5 a6       =         (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi62 f a1 a2 a3 a4 a5 a6       = funzip2 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi63 f a1 a2 a3 a4 a5 a6       = funzip3 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi64 f a1 a2 a3 a4 a5 a6       = funzip4 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi65 f a1 a2 a3 a4 a5 a6       = funzip5 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi66 f a1 a2 a3 a4 a5 a6       = funzip6 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi67 f a1 a2 a3 a4 a5 a6       = funzip7 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi68 f a1 a2 a3 a4 a5 a6       = funzip8 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6)
psi71 f a1 a2 a3 a4 a5 a6 a7    =         (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi72 f a1 a2 a3 a4 a5 a6 a7    = funzip2 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi73 f a1 a2 a3 a4 a5 a6 a7    = funzip3 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi74 f a1 a2 a3 a4 a5 a6 a7    = funzip4 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi75 f a1 a2 a3 a4 a5 a6 a7    = funzip5 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi76 f a1 a2 a3 a4 a5 a6 a7    = funzip6 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi77 f a1 a2 a3 a4 a5 a6 a7    = funzip7 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi78 f a1 a2 a3 a4 a5 a6 a7    = funzip8 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7)
psi81 f a1 a2 a3 a4 a5 a6 a7 a8 =         (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)
psi82 f a1 a2 a3 a4 a5 a6 a7 a8 = funzip2 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)
psi83 f a1 a2 a3 a4 a5 a6 a7 a8 = funzip3 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)
psi84 f a1 a2 a3 a4 a5 a6 a7 a8 = funzip4 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)
psi85 f a1 a2 a3 a4 a5 a6 a7 a8 = funzip5 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)
psi86 f a1 a2 a3 a4 a5 a6 a7 a8 = funzip6 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)
psi87 f a1 a2 a3 a4 a5 a6 a7 a8 = funzip7 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)
psi88 f a1 a2 a3 a4 a5 a6 a7 a8 = funzip8 (f >$ a1 >* a2 >* a3 >* a4 >* a5 >* a6 >* a7 >* a8)


store1 buff a1                      = buff >% a1
store2 buff a1 a2                   = buff >% a1 >% a2
store3 buff a1 a2 a3                = buff >% a1 >% a2 >% a3
store4 buff a1 a2 a3 a4             = buff >% a1 >% a2 >% a3 >% a4
store5 buff a1 a2 a3 a4 a5          = buff >% a1 >% a2 >% a3 >% a4 >% a5
store6 buff a1 a2 a3 a4 a5 a6       = buff >% a1 >% a2 >% a3 >% a4 >% a5 >% a6
store7 buff a1 a2 a3 a4 a5 a6 a7    = buff >% a1 >% a2 >% a3 >% a4 >% a5 >% a6 >% a7
store8 buff a1 a2 a3 a4 a5 a6 a7 a8 = buff >% a1 >% a2 >% a3 >% a4 >% a5 >% a6 >% a7 >% a8


