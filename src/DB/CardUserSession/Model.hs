{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}

module DB.CardUserSession.Model where

import Prelude hiding (id)
-- import Control.Applicative (pure)    
import Data.Text
-- import Data.Maybe (fromJust) -- evil and bad :(    
import GHC.Generics
import Data.Aeson
import Data.UUID    
import Data.Time.Clock
import Control.Applicative
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow

data CardUserSession = CardUserSession
    { id :: UUID
    , user_id :: Int
    , expires :: UTCTime
    } deriving (Generic, Show)

instance ToJSON UUID where
    toJSON = toJSON . toString
instance FromJSON UUID where
    parseJSON (String t) = case (fromString $ unpack t) of
                             Nothing -> fail "Invalid UUID string"
                             Just uuid -> pure uuid
    parseJSON _ = fail "Not a UUID, and it wasn't a string either."

instance FromJSON CardUserSession
instance ToJSON CardUserSession


    
instance FromRow CardUserSession where
    fromRow = CardUserSession <$> field
                              <*> field
                              <*> field
