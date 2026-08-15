
-- DS 8205 D      1 aus 8 Dekoder

library ieee;
use ieee.std_logic_1164.all;


entity DS8205D is
port
(
    a0      : in  std_ulogic;
    a1      : in  std_ulogic;
    a2      : in  std_ulogic;
    --
    e1_n    : in  std_ulogic;
    e2_n    : in  std_ulogic;
    e3      : in  std_ulogic;
    --
    y_n     : out std_ulogic_vector( 7 downto 0)
);
end entity DS8205D;


architecture struct of DS8205D is

    signal en   : std_ulogic;
    signal a0_n : std_ulogic;
    signal a1_n : std_ulogic;
    signal a2_n : std_ulogic;

begin

    en      <= not e1_n and not e2_n and e3;

    a0_n    <= not a0;
    a1_n    <= not a1;
    a2_n    <= not a2;

    y_n( 0) <= not( a0_n and a1_n and a2_n and en); 
    y_n( 1) <= not( a0   and a1_n and a2_n and en); 
    y_n( 2) <= not( a0_n and a1   and a2_n and en); 
    y_n( 3) <= not( a0   and a1   and a2_n and en); 
    y_n( 4) <= not( a0_n and a1_n and a2   and en); 
    y_n( 5) <= not( a0   and a1_n and a2   and en); 
    y_n( 6) <= not( a0_n and a1   and a2   and en); 
    y_n( 7) <= not( a0   and a1   and a2   and en); 

end architecture struct;
