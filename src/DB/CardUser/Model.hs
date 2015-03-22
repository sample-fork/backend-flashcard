{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}

module DB.CardUser.Model where

import Prelude hiding (id)
import Data.Text
import GHC.Generics
import Data.Aeson
import Data.Time.Clock
import Control.Applicative
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow


data CardUser = CardUser
  { id :: Int
  , username :: Text
  , password :: Text
  , email :: Text
  , deleted :: Bool
  , created_on :: UTCTime
  } deriving (Generic, Show)

-- This probably isn't useful, at least at first.
-- instance FromJSON CardUser

-- We musn't hand out people's passwords! They don't like that.
instance ToJSON CardUser where
  toJSON user = object [ "id" .= id user
                       , "username" .= username user
                       , "email" .= email user
                       , "created_on" .= (toJSON $ created_on user)
                       ]

instance FromRow CardUser where
  fromRow = CardUser <$> field 
                     <*> field 
                     <*> field 
                     <*> field 
                     <*> field 
                     <*> field
