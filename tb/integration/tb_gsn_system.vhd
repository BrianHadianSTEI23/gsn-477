library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_gsn_system is
end entity tb_gsn_system;

architecture sim of tb_gsn_system is

    constant CLK_PERIOD : time := 20 ns;

    signal clk_in        : std_logic := '0';
    signal rst           : std_logic := '0';

    signal pc_out        : std_logic_vector(3 downto 0);
    signal op_out        : std_logic_vector(3 downto 0);
    signal a_out         : std_logic_vector(3 downto 0);
    signal b_out         : std_logic_vector(3 downto 0);
    signal fb_out        : std_logic_vector(3 downto 0);
    signal ansi_char_out : std_logic_vector(7 downto 0);
    signal halted_out    : std_logic;

    signal sim_end       : boolean := false;

    -- Helper function to convert 8-bit std_logic_vector to character
    function to_char(slv : std_logic_vector(7 downto 0)) return character is
    begin
        return character'val(to_integer(unsigned(slv)));
    end function;

    -- Helper function to map opcode to readable string
    function op_to_str(op : std_logic_vector(3 downto 0)) return string is
    begin
        case op is
            when "0000" => return "NOP";
            when "0001" => return "LDA";
            when "0010" => return "ADD";
            when "0011" => return "SUB";
            when "0100" => return "LDB";
            when "0101" => return "RND";
            when "1111" => return "HLT";
            when others => return "UNK";
        end case;
    end function;

begin

    -- Instantiate Top-Level CPU System
    uut: entity work.gsn
        port map (
            clk_in        => clk_in,
            rst           => rst,
            pc_out        => pc_out,
            op_out        => op_out,
            a_out         => a_out,
            b_out         => b_out,
            fb_out        => fb_out,
            ansi_char_out => ansi_char_out,
            halted_out    => halted_out
        );

    -- Oscillator Clock Generation
    clk_gen: process
    begin
        while not sim_end loop
            clk_in <= '0';
            wait for CLK_PERIOD / 2;
            clk_in <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Terminal Visualization & System Verification Process
    visual_render_proc: process
        variable l : line;
        variable cycle_count : integer := 0;
    begin
        write(l, string'("=========================================================="));
        writeline(output, l);
        write(l, string'("       GSN477 4-BIT CPU SYSTEM VISUAL RENDERER            "));
        writeline(output, l);
        write(l, string'("=========================================================="));
        writeline(output, l);

        -- Apply System Reset
        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 20 ns;

        write(l, string'("[SYSTEM] Reset released. Initializing execution sequence..."));
        writeline(output, l);
        write(l, string'("----------------------------------------------------------"));
        writeline(output, l);

        -- Run until CPU halts or safety limit (100 cycles) is reached
        while (halted_out = '0') and (cycle_count < 100) loop
            wait until rising_edge(clk_in);
            cycle_count := cycle_count + 1;

            -- Print execution frame every instruction boundary (when PC updates)
            write(l, string'("| Cycle: ") & integer'image(cycle_count));
            write(l, string'(" | PC: ") & to_hstring(pc_out));
            write(l, string'(" | OP: ") & op_to_str(op_out) & string'(" (") & to_hstring(op_out) & string'(")"));
            write(l, string'(" | RegA: ") & to_hstring(a_out));
            write(l, string'(" | RegB: ") & to_hstring(b_out));
            write(l, string'(" | Display: [ ") & to_hstring(ansi_char_out) & string'(" ] |"));
            writeline(output, l);

            wait for 1 ns;
        end loop;

        write(l, string'("----------------------------------------------------------"));
        writeline(output, l);

        if halted_out = '1' then
            write(l, string'("[SYSTEM] SUCCESS: HLT Instruction executed. CPU Halted gracefully."));
            writeline(output, l);
        else
            write(l, string'("[SYSTEM] WARNING: Maximum execution cycles reached without HLT."));
            writeline(output, l);
        end if;

        write(l, string'("=========================================================="));
        writeline(output, l);

        sim_end <= true;
        wait;
    end process;

end architecture sim;