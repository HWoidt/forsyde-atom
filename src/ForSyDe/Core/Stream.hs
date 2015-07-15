{-# OPTIONS_HADDOCK hide #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  ForSyDe.Core.Stream
-- Copyright   :  (c) George Ungureanu, KTH/ICT/ESY 2015
-- License     :  BSD-style (see the file LICENSE)
-- 
-- Maintainer  :  ugeorge@kth.se
-- Stability   :  experimental
-- Portability :  portable
--
-- This module defines the shallow-embedded 'Stream' datatype and
-- functions operating on it.
-----------------------------------------------------------------------------
module ForSyDe.Core.Stream (
  Stream (..),
  stream, fromStream,
) where

-- | A  stream is defined as a list of events. An event has a tag and a value. 
--   The tag of an event is defined by the position in the list. 
--
--   This is the base data type for the 'ForSyDe.MoC.MoC'-bound signals, which are further described
--   by becoming instances of the 'Signal' type class.
data Stream a = a :- Stream a | NullS

infixr 3 :-
  
-- | 'Show' instance for a SY signal. The signal 1 :- 2 :- NullS is represented as \{1,2\}.
instance (Show a) => Show (Stream a) where
  showsPrec p = showParen (p>1) . showStream
    where
      showStream (x :- xs)  = showChar '{' . showEvent x . showStream' xs
      showStream (NullS)     = showChar '{' . showChar '}'
      showStream' (x :- xs) = showChar ',' . showEvent x . showStream' xs
      showStream' (NullS)    = showChar '}'
      showEvent x           = shows x

-- | 'Read' instance for a SY signal. The signal 1 :- 2 :- NullS is read using the string \"\{1,2\}\".
instance (Read a) => Read (Stream a) where
  readsPrec d = readParen (d>1) readStreamStart
    where
      readStreamStart = (\ a -> [(xs,c) | ("{",b) <- lex a , (xs,c) <- readStream (',' : b) ++ readNull b])
      readStream r    = readEvent r ++ readNull r
      readEvent a     = [(x :- xs,d) | (",",b) <- lex a , (x,c) <- reads b , (xs,d) <- readStream c]
      readNull a      = [(NullS,b) | ("}",b) <- lex a]

-- | The function 'signal' converts a list into a signal.
stream :: [a] -> Stream a 
stream []     = NullS
stream (x:xs) = x :- (stream xs)

-- | The function 'fromStream' converts a signal into a list.
fromStream :: Stream a -> [a]
fromStream NullS   = []
fromStream (x:-xs) = x : fromStream xs

