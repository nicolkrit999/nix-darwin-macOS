{ lib, pkgs, ... }:
let
  customLinemode = ''
    -- 1. Custom Metadata Linemode
    function Linemode:custom_metadata()
        local size = self._file:size()
        local size_mb = size and string.format("%.2f MB", size / 1024 / 1024) or "-"
        local btime = math.floor(self._file.cha.btime or 0)
        local btime_str = btime ~= 0 and os.date("%d.%m.%y", btime) or "unk"
        local mtime = math.floor(self._file.cha.mtime or 0)
        local mtime_str = mtime ~= 0 and os.date("%d.%m.%y", mtime) or "unk"
        return string.format(" %s | mod: %s | cre: %s ", size_mb, mtime_str, btime_str)
    end

    require("relative-motions"):setup({
        show_numbers = "relative",
        show_motion = true,
        enter_mode = "first"
    })
  '';
in
{
  # This is cross-platform (macOS OK)
  xdg.configFile."yazi/init.lua".text = customLinemode;

}
