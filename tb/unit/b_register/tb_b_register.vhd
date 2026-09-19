library ieee;
use ieee.std_logic_1164.all;

entity tb_b_register is
end entity tb_b_register;

architecture sim of tb_b_register is

    constant CLK_PERIOD : time := 20 ns;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal load_b  : std_logic := '0';
    signal data_in : std_logic_vector(3 downto 0) := (others => '0');
    signal b_out   : std_logic_vector(3 downto 0);

    signal sim_end : boolean := false;

begin

    uut: entity work.b_register
        port map (
            clk     => clk,
            rst     => rst,
            load_b  => load_b,
            data_in => data_in,
            b_out   => b_out
        );

    clk_gen: process
    begin
        while not sim_end loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        report "--- Starting Register B Unit Test ---";

        rst <= '1';
        wait for 40 ns;
        assert b_out = "0000" report "FAIL: Register B reset failed" severity failure;
        rst <= '0';
        wait for 20 ns;

        -- Load "0110" into Register B
        wait until falling_edge(clk);
        data_in <= "0110";
        load_b  <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;
        assert b_out = "0110" report "FAIL: Register B did not store 0110" severity failure;

        -- Hold value
        load_b  <= '0';
        data_in <= "0001";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert b_out = "0110" report "FAIL: Register B changed without load_b signal" severity failure;

        sim_end <= true;
        report "=== REGISTER B TEST PASSED ===";
        wait;
    end process;

end architecture sim;