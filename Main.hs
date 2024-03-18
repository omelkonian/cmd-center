{-# LANGUAGE PatternSynonyms, LambdaCase #-}
module Main where

import System.Directory (doesFileExist)
import System.Environment (getArgs)
import Data.Maybe (mapMaybe)
import Control.Monad (when)

import Language.Bash.Syntax
import Language.Bash.Pretty (prettyText)
import Language.Bash.Parse (parse)

pattern Fun :: String -> List -> Statement
pattern Fun s stmts =
  Statement
    (Last (Pipeline
      { timed = False
      , timedPosix = False
      , inverted = False
      , commands = [ Command (FunctionDef s stmts) [] ]}))
    Sequential

readFunctions :: FilePath -> IO [String]
readFunctions fname = do
  contents <- readFile fname
  return $ case parse fname contents of
    Left _ -> []
    Right (List cmds) -> mapMaybe (\case {(Fun s _) -> Just s; _ -> Nothing}) cmds

writeScript :: FilePath -> [String] -> List
writeScript fname funs = case parse "" script of
  Left err -> error (show err)
  Right cmds -> cmds
  where
    script :: String
    script = "source \'" <> fname <> "\'\n"
          <> "cmd=$1 && shift\n"
          <> "case \"$cmd\" in\n"
          <> concatMap (\s -> "\t\"" <> s <> "\") " <> s <> " \"$@\" ;;\n") funs
          <> "esac\n"

main :: IO ()
main = do
  [fin] <- getArgs
  let ext  = reverse $ takeWhile (/= '.') (reverse fin)
      base = take (length fin - (length ext + 1)) fin
      fout = base <> "-controls." <> ext
  exists <- doesFileExist fout
  when (not exists) $ do
    funs <- readFunctions fin
    -- putStrLn $ "Funs: " <> show funs
    let script = prettyText $ writeScript fin funs
    -- putStrLn $ "Script: " <> show script
    writeFile fout ("#!/bin/bash\n" <> script)

