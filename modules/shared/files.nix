{ pkgs, config, ... }:
{
  ".ideavimrc" = {
    source = ../../files/shared/.ideavimrc;
  };
  "idea-project.xml" = {
    source = ../../files/shared/idea-project.xml;
  };

}
