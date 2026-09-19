library ieee;
use ieee.std_logic_1164.all;

entity tb_a_register is
end entity tb_a_register;

architecture sim of tb_a_register is

    constant CLK_PERIOD : time := 20 ns;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal load_a   : std_logic := '0';
    signal en_a_bus : std_logic := '0';
    
    signal data_bus : std_logic_vector(3 downto 0) := (others => 'Z');
    signal a_out    : std_logic_vector(3 downto 0);
    
    -- Testbench bus driver signal
    signal tb_drive_bus : std_logic_vector(3 downto 0) := (others => 'Z');
    signal sim_end      : boolean := false;

begin

    -- Tri-state driving of shared data bus from testbench
    data_bus <= tb_drive_bus;

    -- Instantiate UUT
    uut: entity work.a_register
        port map (
            clk      => clk,
            rst      => rst,
            load_a   => load_a,
            en_a_bus => en_a_bus,
            data_bus => data_bus,
            a_out    => a_out
        );

    -- Clock Process
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

    -- Stimulus Process
    stim_proc: process
    begin
        report "--- Starting Register A Unit Test ---";

        -- Reset check
        rst <= '1';
        wait for 40 ns;
        assert a_out = "0000" report "FAIL: Register A reset failed" severity failure;
        rst <= '0';
        wait for 20 ns;

        -- Test Case 1: Load "1010" from Data Bus
        report "--- Case 1: Loading 1010 into Register A ---";
        wait until falling_edge(clk);
        tb_drive_bus <= "1010";
        load_a       <= '1';
        
        wait until rising_edge(clk);
        wait for 1 ns;
        assert a_out = "1010" report "FAIL: Register A did not store 1010" severity failure;
        report "SUCCESS: Register A loaded 1010 to ALU output port.";

        -- Test Case 2: Hold value when load_a = '0'
        report "--- Case 2: Holding stored value ---";
        load_a       <= '0';
        tb_drive_bus <= "1111"; -- Bus changes, register should hold "1010"
        wait until rising_edge(clk);
        wait for 1 ns;
        assert a_out = "1010" report "FAIL: Register A changed without load signal!" severity failure;

        -- Test Case 3: Drive Data Bus Output (Tri-State)
        report "--- Case 3: Bus Driver Enable (en_a_bus) ---";
        tb_drive_bus <= (others => 'Z'); -- Release testbench bus drive
        wait for 10 ns;
        assert data_bus = "ZZZZ" report "FAIL: Bus should be high-Z when disabled" severity failure;

        en_a_bus <= '1';
        wait for 10 ns;
        assert data_bus = "1010" report "FAIL: Register A failed to drive 1010 onto Data Bus" severity failure;
        report "SUCCESS: Register A drove 1010 onto Data Bus.";

        en_a_bus <= '0';
        wait for 10 ns;
        assert data_bus = "ZZZZ" report "FAIL: Bus did not return to high-Z" severity failure;

        sim_end <= true;
        report "=== REGISTER A TEST PASSED ===";
        wait;
    end process;

end architecture sim;