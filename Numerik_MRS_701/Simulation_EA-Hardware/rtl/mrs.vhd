library ieee;
use ieee.std_logic_1164.all;

entity mrs is
port
(
    address : in    std_logic_vector( 15 downto 0);
    iorq    : in    std_logic;
    m1      : in    std_logic;
    nmi     : in    std_logic;
    eas     : in    std_logic                       -- wenn low, dann keint Zugriff auf IO-Latches (nur control)
);
end entity mrs;

architecture rtl of mrs is

    signal IODI_n   : std_logic;
    signal bus_adea : std_logic_vector( 14 downto 1);
    signal bus_b5   : std_logic_vector( 5 downto 1);
    signal bus_b6   : std_logic_vector( 8 downto 1);
    signal bus_e    : std_logic_vector( 5 downto 0);
    signal d13_o    : std_logic_vector( 9 downto 0);
    signal d14_04   : std_logic;
    signal d16_10   : std_logic;
    signal d16_11   : std_logic;
    signal d25_do   : std_ulogic_vector( 3 downto 0);
    signal d27_y    : std_ulogic_vector( 7 downto 0);
    signal d28_06   : std_logic;
    signal d28_11   : std_logic;
    signal d29_06   : std_logic;
    signal d29_08   : std_logic;
    signal en_inp   : std_logic;
    signal mrs_ff   : std_logic;

begin

    IODI_n  <= 'H'; -- pull-up, wenn low, dann alle IO-Zugriffe unterbunden

    D27: entity work.DS8205
    port map
    (
        a0      => address( 4),     --: in  std_ulogic;
        a1      => address( 5),     --: in  std_ulogic;
        a2      => address( 6),     --: in  std_ulogic;
        --                        
        e1_n    => address( 7),     --: in  std_ulogic;
        e2_n    => iorq,            --: in  std_ulogic;
        e3      => d28_11,          --: in  std_ulogic;
        --
        y_n     => d27_y            --: out std_ulogic_vector( 7 downto 0)
    );
    bus_e <= (
        0 => d27_y( 1),
        1 => d27_y( 2),
        2 => d27_y( 4),
        3 => d27_y( 5),
        4 => d27_y( 6),
        5 => d27_y( 7));

    D28_a: d28_11 <= IODI_n and m1;
    D28_b: d28_06 <= nmi    and mrs_ff;

    D29_a: d29_08 <= not( bus_e( 3) and d29_06);
    D29_b: d29_06 <= not( bus_e( 4) and d29_08);

    mrs_ff <= d29_06;


    D25: entity work.DL175D
    port map
    (
        di   => to_x01( address( 11 downto 8)),  --: in  std_ulogic_vector( 3 downto 0);
        clk  => bus_e( 5),              --: in  std_ulogic;
        r_n  => 'H',                    --: in  std_ulogic;
        --
        do   => d25_do,                 --: out std_ulogic_vector( 3 downto 0);
        do_n => open                    --: out std_ulogic_vector( 3 downto 0)
    );


    -- nichtinvertierende Optokoppler
    U8:  bus_b5( 1) <= '0' when d25_do(0) = '0' else 'H';
    U15: bus_b5( 2) <= '0' when d25_do(1) = '0' else 'H';
    U14: bus_b5( 3) <= '0' when d25_do(2) = '0' else 'H';
    U7:  bus_b5( 4) <= '0' when d25_do(3) = '0' else 'H';
    U13: bus_b5( 5) <= '0' when d28_06  = '0' else 'H';

    D13: entity work.V4028D
    port map
    (
        a   => bus_b5( 4 downto 1), --: in  std_ulogic_vector( 3 downto 0);
        q   => d13_o                --: out std_ulogic_vector( 9 downto 0)
    );
    bus_b6 <= (
        1 => d13_o( 0),
        2 => d13_o( 1),
        3 => d13_o( 2),
        4 => d13_o( 3),
        5 => d13_o( 4),
        6 => d13_o( 5),
        7 => d13_o( 6),
        8 => d13_o( 7));
    en_inp <= d13_o( 9);

    D16_a: d16_10  <= not( bus_b5( 5));
    D16_b: d16_11  <= not( d16_10 and eas);
    D14_a: d14_04  <= not( d16_11);

    -- inputs
    D12_a: bus_adea(  1) <= not( bus_b6( 1) and d14_04);
    D12_b: bus_adea(  2) <= not( bus_b6( 2) and d14_04);
    D15_a: bus_adea(  3) <= not( bus_b6( 3) and d14_04);
    D17_a: bus_adea(  4) <= not( bus_b6( 4) and d14_04);
    D15_b: bus_adea(  5) <= not( bus_b6( 5) and d14_04);
    -- control           
    D17_b: bus_adea(  6) <= not( en_inp     and d16_10);
    -- outputs          
    D12_c: bus_adea(  7) <= not( bus_b6( 1) and eas);
    D12_d: bus_adea(  8) <= not( bus_b6( 2) and eas);
    D15_c: bus_adea(  9) <= not( bus_b6( 3) and eas);
    D17_c: bus_adea( 10) <= not( bus_b6( 4) and eas);
    D15_d: bus_adea( 11) <= not( bus_b6( 5) and eas);
    D14_b: bus_adea( 12) <= not( bus_b6( 6) and eas);
    D14_c: bus_adea( 13) <= not( bus_b6( 7) and eas);
    D14_d: bus_adea( 14) <= not( bus_b6( 8) and eas);

end architecture rtl;
