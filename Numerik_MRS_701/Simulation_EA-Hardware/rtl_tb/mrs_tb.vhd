library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mrs_tb is
end entity mrs_tb;


architecture testbench of mrs_tb is

    signal simlation_run    : boolean := true;

    signal io         : natural;
    signal io_modul   : natural;
    signal tb_address : std_logic_vector( 15 downto 0);
    signal tb_iorq    : std_logic;
    signal tb_m1      : std_logic;
    signal tb_nmi     : std_logic;
    signal tb_eas     : std_logic;

    procedure iorq_pulse( signal iorq_n : out std_logic) is
    begin
        iorq_n <= '0';
        wait for 30 ns;
        iorq_n <= '1';
        wait for 30 ns;
    end procedure iorq_pulse;

begin

    tb_nmi      <= 'H';

    dut: entity work.mrs
    port map
    (
        address => tb_address, --: in    std_logic_vector( 15 downto 0);
        iorq    => tb_iorq,    --: in    std_logic;
        m1      => tb_m1,      --: in    std_logic
        nmi     => tb_nmi,     --: in    std_logic
        eas     => tb_eas      --: in    std_logic
    );

    main: process
    begin
        tb_address  <= x"0000";
        tb_iorq     <= '1';
        tb_m1       <= '1';
        tb_eas      <= '0';
        io          <= 0;
        io_modul    <= 0;

        wait for 1 us;

        report "loop IO range 00h..70h, EAS = 0, io_modul = 0";
        for i in 0 to 7 loop
            tb_address  <= std_logic_vector( to_unsigned( io_modul * 256 + i * 16, tb_address'length));
            wait for 100 ns;

            iorq_pulse( tb_iorq);

            tb_m1   <= '0';
            wait for 30 ns;
            tb_m1   <= '1';
            wait for 30 ns;

            wait for 100 ns;

        end loop;
        report "reset IO latch";
        tb_address  <= std_logic_vector( to_unsigned( 15 * 256 + 16#70#, tb_address'length));
        wait for 100 ns;

        iorq_pulse( tb_iorq);
        wait for 1 us;


        report "loop IO-modul 0..15, EAS = 0, IO = 70h";
        tb_eas  <= '0';
        io      <= 16#70#;
        wait for 100 ns;

        for i in 0 to 9 loop
            tb_address  <= std_logic_vector( to_unsigned( i * 256 + io, tb_address'length));
            wait for 100 ns;

            iorq_pulse( tb_iorq);

            -- ff reset
            tb_address  <= std_logic_vector( to_unsigned( i * 256 + 16#50#, tb_address'length));
            wait for 100 ns;
            iorq_pulse( tb_iorq);

            -- ff set
            tb_address  <= std_logic_vector( to_unsigned( i * 256 + 16#60#, tb_address'length));
            wait for 100 ns;
            iorq_pulse( tb_iorq);

            wait for 100 ns;

        end loop;
        wait for 1 us;


        report "loop IO-modul 0..15, EAS = 1, IO = 70h";
        tb_eas  <= '1';
        io      <= 16#70#;
        for i in 0 to 9 loop
            tb_address  <= std_logic_vector( to_unsigned( i * 256 + io, tb_address'length));
            wait for 100 ns;
            iorq_pulse( tb_iorq);

            -- ff reset
            tb_address  <= std_logic_vector( to_unsigned( i * 256 + 16#50#, tb_address'length));
            wait for 100 ns;
            iorq_pulse( tb_iorq);
            
            -- ff set
            tb_address  <= std_logic_vector( to_unsigned( i * 256 + 16#60#, tb_address'length));
            wait for 100 ns;
            iorq_pulse( tb_iorq);
            
            wait for 100 ns;

        end loop;
        

        wait; -- forever
        report "Simulation ends.";
        simlation_run   <= false;
    end process;

end architecture testbench;
