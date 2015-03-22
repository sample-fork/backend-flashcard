{-# LANGUAGE OverloadedStrings #-}
module Routes.Utils where

import Data.Aeson
    
buildErrorResp :: String -> Value
buildErrorResp err = object $ [ "error" .= err ]
    
