{ pkgs, config, ... }:
{
  ".ideavimrc" = {
    source = ../../files/shared/.ideavimrc;
  };
  "idea-project.xml" = {
    source = ../../files/shared/idea-project.xml;
  };
  ".tigrc" = {
    source = ../../files/shared/.tigrc;
  };
  ".config/gh-dash/config.yml" = {
    source = ../../files/shared/gh-dash/config.yml;
  };
  ".vifm/vifm_devicons" = {
    source = ../../files/shared/vifm/vifm_devicons;
  };
  ".vifm/colors/papercolor-dark.vifm" = {
    source = ../../files/shared/vifm/papercolor-dark.vifm;
  };

}
