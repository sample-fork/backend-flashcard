{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}

module DB.CardSimple.Model where

import Prelude hiding (id)
import Data.Text
import GHC.Generics
import Data.Aeson
import Data.Time.Clock
import Control.Applicative
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow


data CardSimple = CardSimple
  { id :: Maybe Int
  , deck_id :: Int
  , front :: Text
  , back :: Text
  , info :: Maybe Text
  , deleted :: Bool
  , created_on :: Maybe UTCTime
  , created_by :: Int
  } deriving (Generic, Show)

instance FromJSON CardSimple
instance ToJSON CardSimple

instance FromRow CardSimple where
  fromRow = CardSimple <$> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
