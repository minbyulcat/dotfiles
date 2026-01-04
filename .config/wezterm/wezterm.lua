local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 1. 기본 설정
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.color_scheme = 'Dracula (Official)'
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"
config.default_cursor_style = 'BlinkingBar'

-- Windows 환경 설정
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = {'powershell.exe'}
  -- 한글 깨짐 방지 및 폰트 설정 (필요시 주석 해제 후 폰트명 입력)
  -- config.font = wezterm.font 'JetBrainsMono Nerd Font'
end

-- 2. 마우스 바인딩 (유지)
config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = act.SelectTextAtMouseCursor 'SemanticZone',
    mods = 'NONE',
  },
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
      end
    end),
  },
}

-- 3. 키 바인딩 설정
-- 모든 기본 키를 끄고 필요한 것만 정의합니다.
config.disable_default_key_bindings = true 

config.keys = {
  ---------------------------------------------------------
  -- (1) Tmux 스타일 키 바인딩
  ---------------------------------------------------------
  -- 화면 분할
  { key = '%', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '"', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Pane 이동 (화살표)
  { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },

  -- Pane 줌 (전체화면 토글)
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  -- Pane 닫기
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- 탭(Window) 관리
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  
  -- [추가] 탭 이름 변경 (Leader + ,) -> Tmux 기본 기능
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- [추가] Copy Mode (Leader + [) -> Tmux 필수 기능!
  -- 화살표나 hjkl로 이동하고 v로 선택, y로 복사할 수 있는 모드입니다.
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },


  ---------------------------------------------------------
  -- (2) 일반 유틸리티 및 수정 사항
  ---------------------------------------------------------
  -- Ctrl+Z 프로세스 중단 (강제 전송)
  -- 기본 키 바인딩을 껐기 때문에, 혹시 몰라 명시적으로 추가합니다.
  { key = 'z', mods = 'CTRL', action = act.SendKey { key = 'z', mods = 'CTRL' } },

  -- 복사 & 붙여넣기 (기본 키를 껐으므로 추가 필요)
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' }, -- 기존 설정 유지

  -- 폰트 크기 조절 (매우 유용함)
  { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },

  -- 설정 리로드
  { key = 'R', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
  -- 전체 화면
  { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
  -- 디버그 오버레이 (설정 꼬였을 때 확인용)
  { key = 'L', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },
}

return config