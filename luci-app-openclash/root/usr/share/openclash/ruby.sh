#!/bin/sh

openclash_custom_overwrite() {
  local pid=$$
  while [ "$pid" != "1" ]; do
    pname=$(tr -d '\0' < /proc/"$pid"/cmdline 2>/dev/null)
    case "$pname" in
      *openclash_custom_overwrite.sh*)
        return 0
        ;;
    esac
    pid=$(awk '/^PPid:/ {print $2}' /proc/"$pid"/status 2>/dev/null)
  done
  return 1
}

ruby_read()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); puts Value$2"
if [ -n "$(echo "$2" |grep '.to_yaml' 2>/dev/null)" ]; then
   ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null |sed '1d' 2>/dev/null
else
   ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
fi
}

ruby_read_hash()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
RUBY_YAML_PARSE="Value = $1; puts Value$2"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_read_hash_arr()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value$2.each do |i| puts i$3 end"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_edit()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; Value$2=$3"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value$2=$3; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_cover()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; if File::exist?('$3') then Value_1 = YAML.load_file('$3'); if not '$4'.empty? then Value$2=Value_1['$4']; else Value$2=Value_1 end else if not '$4'.empty? then Value.delete('$4'); end; end"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); if File::exist?('$3') then Value_1 = YAML.load_file('$3'); if not '$4'.empty? then Value$2=Value_1['$4']; else Value$2=Value_1 end else if not '$4'.empty? then Value.delete('$4'); end; end; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_merge()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; Value_1 = YAML.load_file('$3'); Value$2.merge!(Value_1$4)"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value_1 = YAML.load_file('$3'); Value$2.merge!(Value_1$4); File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_uniq()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; Value$2=Value$2.uniq"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value$2=Value$2.uniq; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_merge_hash()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; Value$2.merge!($3)"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value$2.merge!($3); File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_arr_add_file()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; Value_1 = YAML.load_file('$4'); Value_1$5.reverse.each{|x| Value$2.insert($3,x)}; Value$2=Value$2.uniq"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value_1 = YAML.load_file('$4'); Value_1$5.reverse.each{|x| Value$2.insert($3,x)}; Value$2=Value$2.uniq; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_arr_head_add_file()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; Value_1 = YAML.load_file('$3'); Value$2=(Value_1$4+Value$2).uniq"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value_1 = YAML.load_file('$3'); Value$2=(Value_1$4+Value$2).uniq; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_arr_insert()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; if not Value$2 or Value$2.nil? then Value$2 = []; end; Value$2=Value$2.insert($3,'$4').uniq"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); if not Value$2 or Value$2.nil? then Value$2 = []; end; Value$2=Value$2.insert($3,'$4').uniq; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_arr_insert_hash()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; if not Value$2 or Value$2.nil? then Value$2 = []; end; Value$2=Value$2.insert($3,$4).uniq"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); if not Value$2 or Value$2.nil? then Value$2 = []; end; Value$2=Value$2.insert($3,$4).uniq; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_arr_insert_arr()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$2" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; if not Value$2 or Value$2.nil? then Value$2 = []; end; ${4}.reverse.each{|x| Value$2=Value$2.insert($3,x).uniq}"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); if not Value$2 or Value$2.nil? then Value$2 = []; end; ${4}.reverse.each{|x| Value$2=Value$2.insert($3,x).uniq}; File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}

ruby_delete()
{
local RUBY_YAML_PARSE
if [ -z "$1" ] || [ -z "$3" ]; then
    return
fi
if openclash_custom_overwrite; then
  RUBY_YAML_PARSE="yaml_file_path='$1'; Value$2.delete('$3')"
  echo "threads << Thread.new do $RUBY_YAML_PARSE end" >> /tmp/yaml_openclash_ruby_parse
  return
fi
RUBY_YAML_PARSE="Value = YAML.load_file('$1'); Value$2.delete('$3'); File.open('$1','w') {|f| YAML.dump(Value, f)}"
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "$RUBY_YAML_PARSE" 2>/dev/null
}