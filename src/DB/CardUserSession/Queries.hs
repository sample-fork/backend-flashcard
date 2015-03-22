{-# LANGUAGE OverloadedStrings, RecordWildCards #-}
module DB.CardUserSession.Queries where


import Prelude hiding (id)    
import Control.Monad.IO.Class (liftIO)
import Data.Functor ((<$>))    
import Data.Maybe  (listToMaybe)  
import Data.Monoid
import Data.String (fromString)
import Data.UUID hiding (fromString)
import Data.Text (Text)   
import Database.PostgreSQL.Simple

import Web.Scotty

import DB.CardUser.Model    
import DB.CardUser.Queries
import DB.CardUserSession.Model


getUserFromSession :: Connection -> UUID -> ActionM (Maybe CardUser)
getUserFromSession conn uuid = do
    liftIO $ listToMaybe <$> query conn lookupUserQuery (Only uuid)
  where
    lookupUserQuery :: Query
    lookupUserQuery = fromString $ mconcat 
                                [ "SELECT * FROM carduser WHERE id = " 
                                , "(SELECT user_id FROM carduser_session "
                                , "  WHERE id = ? LIMIT 1)"
                                ]

createSession :: Connection 
              -> Int -- ^ User ID
              -> ActionM (Maybe CardUserSession)
createSession conn userId = 
    liftIO $ listToMaybe <$> query conn createQuery (Only userId)
  where
    createQuery = "INSERT INTO carduser_session (id, user_id, expires) VALUES (gen_random_uuid(), ?, NOW() + '2 WEEKS') RETURNING *"

deleteSession :: Connection
              -> UUID
              -> ActionM Bool
deleteSession conn sessionId = do
  let deleteQuery = "DELETE FROM carduser_session WHERE id = ?"
  numRows <- liftIO $ execute conn deleteQuery (Only sessionId)
  return $ if numRows == 1 then True else False
                  
                  
loginUser :: Connection 
          -> Text -- ^ Username
          -> Text -- ^ Password (plaintext)
          -> ActionM (Maybe CardUserSession)
loginUser conn uname passwd = do
  user <- getUserByCredentials conn uname passwd
  case user of
    Nothing -> return Nothing
    Just (CardUser{..}) -> createSession conn id
