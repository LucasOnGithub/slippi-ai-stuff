@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT_DIR=%~dp0"
pushd "%ROOT_DIR%" >nul
if exist "%ROOT_DIR%\.venv\Scripts\activate.bat" (
    call "%ROOT_DIR%\.venv\Scripts\activate.bat" >nul
)

set "PYTHON_CMD=python"
set "ISO_PATH=__ISO__"
set "VALID_CHARACTERS=FOX MARTH CPTFALCON FALCO PEACH JIGGLYPUFF PIKACHU ZELDA SHEIK SAMUS GANONDORF ROY DOC MARIO LUIGI LINK YLINK DK BOWSER GAMEANDWATCH POPO KIRBY MEWTWO NESS PICHU YOSHI"

call :PROMPT_PLAYER_TYPE 1
call :PROMPT_PLAYER_TYPE 2
call :PROMPT_COPY_HOME

set "ARGS=--dolphin.iso=\"!ISO_PATH!\" --p1.type=!P1_TYPE! --p2.type=!P2_TYPE!"
if /I "!P1_TYPE!"=="ai" (
    set "ARGS=!ARGS! --p1.character=!P1_CHARACTER! --p1.ai.path=\"!P1_AGENT!\""
)
if /I "!P2_TYPE!"=="ai" (
    set "ARGS=!ARGS! --p2.character=!P2_CHARACTER! --p2.ai.path=\"!P2_AGENT!\""
)
if defined COPY_HOME_FLAG (
    set "ARGS=!ARGS! --dolphin.copy_home_directory"
)

echo.
echo Starting Phillip with:
echo     !ARGS!
echo.

"%PYTHON_CMD%" scripts\eval_two.py !ARGS!
set "EXIT_CODE=!ERRORLEVEL!"
popd >nul
exit /b !EXIT_CODE!

:PROMPT_PLAYER_TYPE
set "PORT=%~1"
:PROMPT_PLAYER_TYPE_LOOP
set /p ANSWER=Enter P%PORT% type (human/ai): 
if /I "%ANSWER%"=="human" (
    if "%PORT%"=="1" (
        set "P1_TYPE=human"
    ) else (
        set "P2_TYPE=human"
    )
    goto :PROMPT_PLAYER_TYPE_DONE
)
if /I "%ANSWER%"=="ai" (
    if "%PORT%"=="1" (
        set "P1_TYPE=ai"
    ) else (
        set "P2_TYPE=ai"
    )
    call :COLLECT_AI_INFO %PORT%
    goto :PROMPT_PLAYER_TYPE_DONE
)
echo Invalid type. Please enter "human" or "ai".
goto :PROMPT_PLAYER_TYPE_LOOP

:PROMPT_PLAYER_TYPE_DONE
exit /b 0

:COLLECT_AI_INFO
set "PORT=%~1"
call :ASK_CHARACTER %PORT%
call :ASK_AGENT %PORT%
exit /b 0

:ASK_CHARACTER
set "PORT=%~1"
:ASK_CHARACTER_LOOP
echo.
echo Valid characters:
echo FOX MARTH CPTFALCON FALCO PEACH JIGGLYPUFF PIKACHU ZELDA SHEIK SAMUS GANONDORF ROY DOC MARIO LUIGI LINK YLINK DK BOWSER GAMEANDWATCH POPO KIRBY MEWTWO NESS PICHU YOSHI
set /p CHAR_INPUT=Which character will the AI on P%PORT% use? 
if not defined CHAR_INPUT (
    echo Please enter one of the valid character names.
    goto :ASK_CHARACTER_LOOP
)
set "CHAR_CHOICE="
for %%C in (%VALID_CHARACTERS%) do (
    if /I "%CHAR_INPUT%"=="%%C" (
        set "CHAR_CHOICE=%%C"
    )
)
if not defined CHAR_CHOICE (
    echo Invalid character. Please select from the list.
    goto :ASK_CHARACTER_LOOP
)
if "%PORT%"=="1" (
    set "P1_CHARACTER=%CHAR_CHOICE%"
) else (
    set "P2_CHARACTER=%CHAR_CHOICE%"
)
exit /b 0

:ASK_AGENT
set "PORT=%~1"
:ASK_AGENT_LOOP
echo Which agent will the AI use? Provide the path to the agent, or place it in the root of Phillip and type in its name.
echo Examples: medium-v2
set "AGENT_INPUT="
set /p AGENT_INPUT=Agent path or name for P!PORT!: 
if not defined AGENT_INPUT (
    echo Please provide a value (e.g., medium-v2).
    goto :ASK_AGENT_LOOP
)
set "AGENT_PATH="
for %%P in ("!AGENT_INPUT!") do (
    if exist %%~fP (
        set "AGENT_PATH=%%~fP"
    )
)
if not defined AGENT_PATH (
    for %%P in ("!ROOT_DIR!!AGENT_INPUT!") do (
        if exist %%~fP (
            set "AGENT_PATH=%%~fP"
        )
    )
)
if not defined AGENT_PATH (
    echo Could not find "!AGENT_INPUT!". Ensure the file exists or is placed in the project root.
    goto :ASK_AGENT_LOOP
)
if "!PORT!"=="1" (
    set "P1_AGENT=!AGENT_PATH!"
) else (
    set "P2_AGENT=!AGENT_PATH!"
)
exit /b 0

:PROMPT_COPY_HOME
:PROMPT_COPY_HOME_LOOP
set /p COPY_INPUT=Do you want to pass `--dolphin.copy_home_directory`? This is only needed if you are not using the GameCube controller. (y/n): 
if /I "%COPY_INPUT%"=="y" (
    set "COPY_HOME_FLAG=1"
    goto :PROMPT_COPY_HOME_DONE
)
if /I "%COPY_INPUT%"=="n" (
    set "COPY_HOME_FLAG="
    goto :PROMPT_COPY_HOME_DONE
)
echo Please answer with y or n.
goto :PROMPT_COPY_HOME_LOOP

:PROMPT_COPY_HOME_DONE
exit /b 0
