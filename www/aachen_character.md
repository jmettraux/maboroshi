
# aachen_character
{
str = 3d6; str_tc = 21 - str;
con = 3d6; con_tc = 21 - con;
dex = 3d6; dex_tc = 21 - dex;
int = 3d6; int_tc = 21 - int;
wis = 3d6; wis_tc = 21 - wis;
cha = 3d6; cha_tc = 21 - cha;
body_tc = mean(str_tc, con_tc, dex_tc); body = 21 - body_tc;
soul_tc = mean(int_tc, wis_tc, cha_tc); soul = 21 - soul_tc;
physical_tc = mean(str_tc, con_tc); physical = 21 - physical_tc;
evasion_tc = mean(dex_tc, int_tc); evasion = 21 - evasion_tc;
mental_tc = mean(wis_tc, cha_tc); mental = 21 - mental_tc;
""}

STR D{f2d(str)} T{f2d(str_tc)}    Physical D{f2d(physical)} T{f2d(physical)}
CON D{f2d(con)} T{f2d(con_tc)}  Body D{f2d(body)} T{f2d(body_tc)}
DEX D{f2d(dex)} T{f2d(dex_tc)}
INT D{f2d(int)} T{f2d(int_tc)}    Evasion  D{f2d(evasion)} T{f2d(evasion)}
WIS D{f2d(wis)} T{f2d(wis_tc)}  Soul D{f2d(soul)} T{f2d(soul_tc)}
CHA D{f2d(cha)} T{f2d(cha_tc)}    Mental   D{f2d(mental)} T{f2d(mental)}


## mood

1. Simple-minded
1. Friendly
1. Adventurous
1. Timid
1. Shy
1. Pitiful
1. Cooperative
1. Lovable
1. Ambitious
1. Quiet
1. Curious
1. Reserved
1. Pleasing
1. Bossy
1. Witty
1. Energetic
1. Cheerful
1. Smart
1. Impulsive
1. Humorous
1. Sad
1. Lazy
1. Dreamer
1. Helpful

