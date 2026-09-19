library ieee;
use ieee.std_logic_1164.all;

entity tb_framebuffer_decoder is
end entity tb_framebuffer_decoder;

architecture sim of tb_framebuffer_decoder is

    constant CLK_PERIOD : time := 20 ns;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal load_fb   : std_logic := '0';
    signal data_in   : std_logic_vector(3 downto 0) := (others => '0');
    
    signal fb_out    : std_logic_vector(3 downto 0);
    signal ansi_char : std_logic_vector(7 downto 0);

    signal sim_end   : boolean := false;

begin

    -- Instantiate Unit Under Test
    uut: entity work.framebuffer_decoder
        port map (
            clk       => clk,
            rst       => rst,
            load_fb   => load_fb,
            data_in   => data_in,
            fb_out    => fb_out,
            ansi_char => ansi_char
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
        report "--- Starting Framebuffer Decoder Unit Test ---";

        -- Test Case 1: Global Reset
        rst <= '1';
        wait for 40 ns;
        assert fb_out = "0000" and ansi_char = x"20"
            report "FAIL: Framebuffer failed to initialize to '0000' (space)" severity failure;
        
        rst <= '0';
        wait for 20 ns;
        report "SUCCESS: Reset initialized framebuffer properly.";

        -- Test Case 2: Load '0001' (Pixel level 1 -> '.')
        report "--- Case 2: Loading '0001' ---";
        wait until falling_edge(clk);
        data_in <= "0001";
        load_fb <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;
        assert fb_out = "0001" and ansi_char = x"2E"
            report "FAIL: Framebuffer did not output '.' (0x2E) for 0001" severity failure;
        report "SUCCESS: Framebuffer loaded '0001' -> ASCII '.'";

        -- Test Case 3: Hold Value when load_fb = '0'
        report "--- Case 3: Verify Hold State ---";
        load_fb <= '0';
        data_in <= "1001"; -- Input changes, register should hold "0001"
        wait until rising_edge(clk);
        wait for 1 ns;
        assert fb_out = "0001"
            report "FAIL: Framebuffer updated value without load_fb signal" severity failure;

        -- Test Case 4: Load '1001' (Pixel level 9 -> '@')
        report "--- Case 4: Loading '1001' ---";
        wait until falling_edge(clk);
        data_in <= "1001";
        load_fb <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;
        assert fb_out = "1001" and ansi_char = x"40"
            report "FAIL: Framebuffer did not output '@' (0x40) for 1001" severity failure;
        report "SUCCESS: Framebuffer loaded '1001' -> ASCII '@'";

        load_fb <= '0';
        wait for 20 ns;

        sim_end <= true;
        report "=== FRAMEBUFFER DECODER TEST PASSED ===";
        wait;
    end process;

end architecture sim;