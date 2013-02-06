{-# Language TypeSynonymInstances, FlexibleInstances #-}
module Language.Egison.Types where

import qualified Data.Map
import Data.IORef
import System.IO
import Control.Monad.Error
import Text.ParserCombinators.Parsec hiding (spaces)

--
-- Expressions
--
data EgisonTopExpr =
    Define String EgisonExpr
  | DefineType String DefineTypeExpr
  | DefineClass String DefineClassExpr
  | Instance String [String] [(String, String)]
  | Test EgisonExpr
  | Execute [String]
    -- temporary : we will replace load to import and export
  | LoadFile String
  | Load String
 deriving (Show)

data EgisonExpr =
    CharExpr Char (Maybe EgisonTypeExpr)
  | StringExpr String (Maybe EgisonTypeExpr)
  | BoolExpr Bool (Maybe EgisonTypeExpr)
  | IntegerExpr Integer (Maybe EgisonTypeExpr)
  | FloatExpr Double (Maybe EgisonTypeExpr)
  | PatVarExpr String [EgisonExpr] (Maybe EgisonTypeExpr)
  | VarExpr String [EgisonExpr] (Maybe EgisonTypeExpr)
  | VarNameExpr String (Maybe EgisonTypeExpr)
  | PatVarOmitExpr String [EgisonExpr] (Maybe EgisonTypeExpr)
  | OmitExpr String [EgisonExpr] (Maybe EgisonTypeExpr)

  | WildCardExpr (Maybe EgisonTypeExpr)
  | ValuePatExpr EgisonExpr (Maybe EgisonTypeExpr)
  | CutPatExpr EgisonExpr (Maybe EgisonTypeExpr)
  | NotPatExpr EgisonExpr (Maybe EgisonTypeExpr)
  | AndPatExpr [EgisonExpr] (Maybe EgisonTypeExpr)
  | OrPatExpr [EgisonExpr] (Maybe EgisonTypeExpr)
  | PredPatExpr EgisonExpr [EgisonExpr] (Maybe EgisonTypeExpr)

  | InductiveDataExpr String [EgisonExpr] (Maybe EgisonTypeExpr)
  | TupleExpr [EgisonExpr] (Maybe EgisonTypeExpr)
  | CollectionExpr [InnerExpr] (Maybe EgisonTypeExpr)
  | FuncExpr EgisonExpr EgisonExpr (Maybe EgisonTypeExpr)

  | IfExpr EgisonExpr EgisonExpr EgisonExpr (Maybe EgisonTypeExpr)
  | LetExpr Bindings EgisonExpr (Maybe EgisonTypeExpr)
  | LetRecExpr RecursiveBindings EgisonExpr (Maybe EgisonTypeExpr)
  | DoExpr Bindings EgisonExpr (Maybe EgisonTypeExpr)

  | MatchExpr EgisonExpr EgisonExpr [MatchClause] (Maybe EgisonTypeExpr)
  | MatchAllExpr EgisonExpr EgisonExpr MatchClause (Maybe EgisonTypeExpr)

  | MatcherExpr MatcherInfoExpr (Maybe EgisonTypeExpr)
  
  | ClassExpr ClassInfoExpr (Maybe EgisonTypeExpr)
  | InstanceExpr ClassInfoExpr (Maybe EgisonTypeExpr)

  | ApplyExpr EgisonExpr EgisonExpr (Maybe EgisonTypeExpr)

  | SomethingExpr (Maybe EgisonTypeExpr)
  | UndefinedExpr (Maybe EgisonTypeExpr)
 deriving (Show)

data EgisonTypeExpr =
    CharTypeExpr
  | StringTypeExpr
  | BoolTypeExpr
  | IntegerTypeExpr
  | FloatTypeExpr
  | VarNameTypeExpr
    -- Type variable binded to some type
  | VarTypeExpr String
    -- _ -> _
  | FunTypeExpr EgisonTypeExpr EgisonTypeExpr
    -- (Match _), (Pattern _)
  | MatcherTypeExpr EgisonTypeExpr
  | PatternTypeExpr EgisonTypeExpr
    -- [_ _ ...], (Collection _)
  | TupleTypeExpr [EgisonTypeExpr]
  | CollectionTypeExpr EgisonTypeExpr
    -- (FnType ArgType ...)
  | AppTypeExpr EgisonTypeExpr EgisonTypeExpr
 deriving (Show)
          
data EgisonClassExpr =
    TypeClassExpr
  | VarClassExpr String
  | FunClassExpr EgisonClassExpr EgisonClassExpr
        
type MatchClause = (EgisonExpr, EgisonExpr)

data PrimitivePatPattern =
    PPWildCard
  | PPValuePat String
  | PPInductivePat String [PrimitivePatPattern]
 deriving (Show)

data PrimitivePattern =
    PWildCard
  | PPatVar String
  | PInductivePat String [PrimitivePattern]
  | PEmptyPat
  | PConsPat PrimitivePattern PrimitivePattern
  | PSnocPat PrimitivePattern PrimitivePattern

  | PPatBool Bool
  | PPatChar Char
  | PPatInteger Integer
  | PPatFloat Double
 deriving (Show)

data InnerExpr =
    ElementExpr EgisonExpr
  | SubCollectionExpr EgisonExpr
 deriving (Show)

data InnerTypedExpr =
    ElementTypedExpr EgisonTypedExpr
  | SubCollectionTypedExpr EgisonTypedExpr
 deriving (Show)

type Bindings = [(EgisonExpr, EgisonExpr)]

type RecursiveBindings = [(String, EgisonExpr)]
  
type MatcherInfoExpr = [(PrimitivePatPattern, EgisonExpr, [(PrimitivePattern, EgisonExpr)])]

type ClassInfoExpr = [(String, EgisonTypeExpr)]

--
-- Typed Expression
--

data EgisonTypedExpr =
 Hoge
 deriving (Show)

data DefineTypeExpr =
  Huga
 deriving (Show)

data DefineClassExpr =
  Piyo
 deriving (Show)

data Environment =
  Poyo
 deriving (Show)

--
-- Values
--
type ObjectRef = IORef Object

data Object =
    Closure Env EgisonExpr
  | Pattern EgisonPattern
  | Intermidiate EgisonIntermidiate
  | Value EgisonValue
  
data EgisonType =
    CharType
  | StringType
  | BoolType
  | IntegerType
  | FloatType
  | TypeType
  | ClassType
  | PatternType EgisonType

  | TupleType [EgisonType]
  | CollectionType EgisonType
  | FunType EgisonType EgisonType
  | AppType EgisonType EgisonType

  | PatVarType String
  | VarType String
 deriving (Show)
        
data EgisonPattern =
    WildCard
  | PatVar String [Integer]
  | ValuePat Environment EgisonExpr
  | PredPat Environment EgisonExpr [EgisonExpr]
  | CutPat EgisonPattern
  | NotPat EgisonPattern
  | AndPat [EgisonPattern]
  | OrPat [EgisonPattern]
  | TuplePat [EgisonPattern]
  | InductivePat String [EgisonPattern]

data EgisonIntermidiate =
    IInductiveData String [ObjectRef]
  | ITuple [ObjectRef]
  | ICollection [InnerObject]

data EgisonValue =
    World [Action]
  | Char Char
  | String String
  | Bool Bool
  | Integer Integer
  | Float Double
  | InductiveData String [EgisonValue]
  | Tuple [EgisonValue]
  | Collection [EgisonValue]
  | Matcher MatcherInfo
  | Class ClassInfo
  | Func ObjectRef EgisonExpr Env
  | PrimitiveFunc ([EgisonValue] -> ThrowsError EgisonValue)
  | IOFunc ([EgisonValue] -> IOThrowsError EgisonValue)
  | Port String Handle
  | Something
  | EOF

data InnerObject =
    IElement ObjectRef
  | ISubCollection ObjectRef

data Action =
    OpenInputPort String
  | OpenOutputPort String
  | ClosePort String
  | FlushPort String
  | ReadFromPort String String
  | WriteToPort String String
 deriving (Show)

type MatcherInfo = [(PrimitivePatPattern, ObjectRef, [(Env, PrimitivePattern, EgisonExpr)])]
type ClassInfo = [(String, EgisonType)]

--
-- Internal Data
--
type VarExpr = (String, [EgisonExpr])

type Var = (String, [Integer])

type FrameList = [(Var, ObjectRef)]

type Frame = Data.Map.Map Var ObjectRef

type FrameRef = IORef Frame

data Env = Environment {
        parentEnv :: (Maybe Env), 
        topFrameRef :: FrameRef
    }

data MatchFlag = MAll | MOne
  
data PClosure = PClosure {pcFrame :: FrameList,
                          pcBody :: ObjectRef
                          }

data MAtom = MAtom {pClosure :: PClosure,
                    maTyp :: ObjectRef,
                    maTarget :: ObjectRef
                    }

data MState = MState {msFrame :: FrameList,
                      mAtoms :: [MAtom]
                      }

---
--- Types for Error Handling
---
data EgisonError =
    Parser ParseError
  | TypeMismatch EgisonExpr EgisonType
  | NotImplemented String
  | Default String

showError :: EgisonError -> String
showError (Parser parseErr) = "Parse error at " ++ ": " ++ show parseErr
showError (TypeMismatch expr typ) = "Type error: The type of a expression '" ++ show expr ++ "' is expected to be '" ++ show typ ++ "'"
showError (NotImplemented message) = "Not implemented: " ++ message
showError (Default message) = "Error: " ++ message

instance Show EgisonError where show = showError
instance Error EgisonError where
  noMsg = Default "An error has occurred"
  strMsg = Default

type ThrowsError = Either EgisonError

trapError :: (MonadError e m, Show e) => m String -> m String
trapError action = catchError action (return . show)

extractValue :: ThrowsError a -> a
extractValue (Right val) = val
extractValue (Left _) = error "Unexpected error in extractValue; "

type IOThrowsError = ErrorT EgisonError IO

liftThrows :: ThrowsError a -> IOThrowsError a
liftThrows (Left err) = throwError err
liftThrows (Right val) = return val

runIOThrowsREPL :: IOThrowsError String -> IO String
runIOThrowsREPL action = runErrorT (trapError action) >>= return . extractValue

runIOThrows :: IOThrowsError String -> IO (Maybe String)
runIOThrows action = do
    runState <- runErrorT action
    case runState of
        Left err -> return $ Just (show err)
        Right _ -> return $ Nothing
