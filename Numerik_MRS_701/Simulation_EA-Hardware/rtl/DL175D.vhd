
-- DL 175 D      4 D-Latches                                         SN74LS175

library ieee;
use ieee.std_logic_1164.all;

entity DL175D is
port 
(
    di   : in  std_ulogic_vector( 3 downto 0);
    clk  : in  std_ulogic;
    r_n  : in  std_ulogic;
    --
    do   : out std_ulogic_vector( 3 downto 0);
    do_n : out std_ulogic_vector( 3 downto 0)
);
end entity DL175D;

architecture rtl of DL175D is

    signal ff : std_ulogic_vector( 3 downto 0) := (others => 'L');

begin

    process( clk, r_n)
    begin
        if rising_edge( clk) then
            ff  <= di;
        end if;
        if to_x01( r_n) = '0' then
            ff  <= "0000";
        end if;
    end process;

    do   <= ff;
    do_n <= not ff;

end architecture rtl;
