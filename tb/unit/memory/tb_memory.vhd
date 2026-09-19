library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memory is
end entity tb_memory;

architecture sim of tb_memory is

    constant CLK_PERIOD : time := 20 ns;

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal addr       : std_logic_vector(3 downto 0) := (others => '0');
    signal write_en   : std_logic := '0';
    signal en_mem_bus : std_logic := '0';

    signal data_bus   : std_logic_vector(3 downto 0) := (others => 'Z');
    signal mem_out    : std_logic_vector(3 downto 0);

    signal tb_drive_bus : std_logic_vector(3 downto 0) := (others => 'Z');
    signal sim_end      : boolean := false;

begin

    -- Driver connection for writing to memory from testbench
    data_bus <= tb_drive_bus;

    -- Instantiate Unit Under Test
    uut: entity work.memory
        port map (
            clk        => clk,
            rst        => rst,
            addr       => addr,
            write_en   => write_en,
            en_mem_bus => en_mem_bus,
            data_bus   => data_bus,
            mem_out    => mem_out
        );

    -- Clock Generation
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
        report "--- Starting Memory Unit Test ---";

        -- Test Case 1: Initial Reset and Default Contents Check
        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 20 ns;

        report "--- Case 1: Checking Preloaded RAM Values ---";
        addr <= "0000"; -- Address 0
        wait for 5 ns;
        assert mem_out = "0001" 
            report "FAIL: Addr 0 expected 0001, got " & to_string(mem_out) severity failure;

        addr <= "0001"; -- Address 1
        wait for 5 ns;
        assert mem_out = "0010" 
            report "FAIL: Addr 1 expected 0010, got " & to_string(mem_out) severity failure;

        addr <= "1001"; -- Address 9 (Byte 10)
        wait for 5 ns;
        assert mem_out = "0101" 
            report "FAIL: Addr 9 expected 0101, got " & to_string(mem_out) severity failure;
        report "SUCCESS: Memory preloaded default contents verified.";

        -- Test Case 2: Bus Driving (en_mem_bus)
        report "--- Case 2: Bus Driving Enable ---";
        addr       <= "0010"; -- Address 2 (contains "0100")
        en_mem_bus <= '0';
        wait for 10 ns;
        assert data_bus = "ZZZZ" report "FAIL: Bus should be high-Z when en_mem_bus=0" severity failure;

        en_mem_bus <= '1';
        wait for 10 ns;
        assert data_bus = "0100" report "FAIL: Bus expected 0100 from Addr 2" severity failure;
        report "SUCCESS: Tri-state bus driver functional.";

        en_mem_bus <= '0';
        wait for 10 ns;

        -- Test Case 3: Synchronous Write Operation
        report "--- Case 3: Writing '1011' to Address 3 ---";
        wait until falling_edge(clk);
        addr         <= "0011";   -- Target Address 3
        tb_drive_bus <= "1011";   -- Data to write
        write_en     <= '1';

        wait until rising_edge(clk); -- Clock edge writes data
        wait for 1 ns;
        
        write_en     <= '0';
        tb_drive_bus <= (others => 'Z'); -- Release bus driver
        wait for 5 ns;

        assert mem_out = "1011" 
            report "FAIL: Addr 3 expected written value 1011, got " & to_string(mem_out) severity failure;
        report "SUCCESS: Synchronous memory write completed.";

        sim_end <= true;
        report "=== MEMORY MODULE TEST PASSED ===";
        wait;
    end process;

end architecture sim;