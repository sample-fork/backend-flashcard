{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}

module DB.Deck.Model where

import Prelude hiding (id)
import Data.Text
import GHC.Generics
import Data.Aeson
import Data.Time.Clock
import Control.Applicative
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow


data Deck = Deck
  { id :: Maybe Int
  , name :: Text
  , description :: Text
  , deleted :: Maybe Bool
  , created_on :: Maybe UTCTime
  , created_by :: Int
  } deriving (Generic, Show)

instance FromJSON Deck
instance ToJSON Deck

instance FromRow Deck where
  fromRow = Deck <$> field 
                 <*> field 
                 <*> field 
                 <*> field 
                 <*> field 
                 <*> field
