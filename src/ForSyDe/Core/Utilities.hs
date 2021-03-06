-----------------------------------------------------------------------------
-- |
-- Module      :  ForSyDe.Core.Utilities
-- Copyright   :  (c) George Ungureanu, KTH/ICT/ESY 2015-2016
-- License     :  BSD-style (see the file LICENSE)
-- 
-- Maintainer  :  ugeorge@kth.se
-- Stability   :  experimental
-- Portability :  portable
--
-- This module implements general purpose utility functions. It mainly
-- hosts functions dealing with tuples. Utilities are provided for up
-- until 8-tuples. Follow the examples in the source code in case it
-- does not suffice.
-----------------------------------------------------------------------------

module ForSyDe.Core.Utilities(
  -- * @at@ functions
  
  -- | The @at@/xy/ functions return the /y/-th element of an
  -- /x/-tuple.
  
  at21, at22,
  at31, at32, at33,
  at41, at42, at43, at44,
  at51, at52, at53, at54, at55,
  at61, at62, at63, at64, at65, at66, 
  at71, at72, at73, at74, at75, at76, at77,
  at81, at82, at83, at84, at85, at86, at87, at88,

  -- * @funzip@ functions

  -- | The @funzip@/x/ name stands for "functor unzip" and, as the
  -- name suggests, it "lifts" a functor of /x/-tuple into an /x/-tuple
  -- of functor.

  funzip2, funzip3, funzip4, funzip5, funzip6, funzip7, funzip8,

  -- * The @unzip@ utilities

  -- | They are implemented as double @funzip@s, and provided as
  -- postfix operators. They are used for uzipping MoC atoms.

  (-<),
  (-<<),
  (-<<<),
  (-<<<<),
  (-<<<<<),
  (-<<<<<<),
  (-<<<<<<<),
  
  ) where

import Prelude hiding (unzip3, filter)

at21 (x,_)             = x
at22 (_,x)             = x
at31 (x,_,_)           = x
at32 (_,x,_)           = x
at33 (_,_,x)           = x
at41 (x,_,_,_)         = x
at42 (_,x,_,_)         = x
at43 (_,_,x,_)         = x
at44 (_,_,_,x)         = x
at51 (x,_,_,_,_)       = x
at52 (_,x,_,_,_)       = x
at53 (_,_,x,_,_)       = x
at54 (_,_,_,x,_)       = x
at55 (_,_,_,_,x)       = x
at61 (x,_,_,_,_,_)     = x
at62 (_,x,_,_,_,_)     = x
at63 (_,_,x,_,_,_)     = x
at64 (_,_,_,x,_,_)     = x
at65 (_,_,_,_,x,_)     = x
at66 (_,_,_,_,_,x)     = x
at71 (x,_,_,_,_,_,_)   = x
at72 (_,x,_,_,_,_,_)   = x
at73 (_,_,x,_,_,_,_)   = x
at74 (_,_,_,x,_,_,_)   = x
at75 (_,_,_,_,x,_,_)   = x
at76 (_,_,_,_,_,x,_)   = x
at77 (_,_,_,_,_,_,x)   = x
at81 (x,_,_,_,_,_,_,_) = x
at82 (_,x,_,_,_,_,_,_) = x
at83 (_,_,x,_,_,_,_,_) = x
at84 (_,_,_,x,_,_,_,_) = x
at85 (_,_,_,_,x,_,_,_) = x
at86 (_,_,_,_,_,x,_,_) = x
at87 (_,_,_,_,_,_,x,_) = x
at88 (_,_,_,_,_,_,_,x) = x

funzip2 x = (at21 <$> x,
             at22 <$> x)
funzip3 x = (at31 <$> x,
             at32 <$> x,
             at33 <$> x)
funzip4 x = (at41 <$> x,
             at42 <$> x,
             at43 <$> x,
             at44 <$> x)
funzip5 x = (at51 <$> x,
             at52 <$> x,
             at53 <$> x,
             at54 <$> x,
             at55 <$> x)
funzip6 x = (at61 <$> x,
             at62 <$> x,
             at63 <$> x,
             at64 <$> x,
             at65 <$> x,
             at66 <$> x)
funzip7 x = (at71 <$> x,
             at72 <$> x,
             at73 <$> x,
             at74 <$> x,
             at75 <$> x,
             at76 <$> x,
             at77 <$> x)
funzip8 x = (at81 <$> x,
             at82 <$> x,
             at83 <$> x,
             at84 <$> x,
             at85 <$> x,
             at86 <$> x,
             at87 <$> x,
             at88 <$> x)

infixl 3 -<, -<<, -<<<, -<<<<, -<<<<<, -<<<<<<, -<<<<<<<
(-<)       s = funzip2 (funzip2 <$> s)
(-<<)      s = funzip3 (funzip3 <$> s)
(-<<<)     s = funzip4 (funzip4 <$> s)
(-<<<<)    s = funzip5 (funzip5 <$> s)
(-<<<<<)   s = funzip6 (funzip6 <$> s)
(-<<<<<<)  s = funzip7 (funzip7 <$> s)
(-<<<<<<<) s = funzip8 (funzip8 <$> s)
