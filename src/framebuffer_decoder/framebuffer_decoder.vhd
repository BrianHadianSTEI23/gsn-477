library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity framebuffer_decoder is
    port (
        clk       : in  std_logic;                    -- System clock
        rst       : in  std_logic;                    -- Global reset
        load_fb   : in  std_logic;                    -- Write enable / latch signal
        data_in   : in  std_logic_vector(3 downto 0); -- 4-bit data input
        fb_out    : out std_logic_vector(3 downto 0); -- Latched 4-bit pixel state
        ansi_char : out std_logic_vector(7 downto 0)  -- 8-bit ASCII character encoding
    );
end entity framebuffer_decoder;

architecture behavioral of framebuffer_decoder is
    signal fb_reg : std_logic_vector(3 downto 0) := (others => '0');
begin

    -- Synchronous Latch Process
    process(clk, rst)
    begin
        if rst = '1' then
            fb_reg <= (others => '0');
        elsif rising_edge(clk) then
            if load_fb = '1' then
                fb_reg <= data_in;
            end if;
        end if;
    end process;

    fb_out <= fb_reg;

    -- Monochrome Display Decoder (4-bit intensity / symbol mapping to ASCII)
    process(fb_reg)
    begin
        case fb_reg is
            when "0000" => ansi_char <= x"20"; -- ' ' (Space / Off)
            when "0001" => ansi_char <= x"2E"; -- '.'
            when "0010" => ansi_char <= x"3A"; -- ':'
            when "0011" => ansi_char <= x"2D"; -- '-'
            when "0100" => ansi_char <= x"3D"; -- '='
            when "0101" => ansi_char <= x"2B"; -- '+'
            when "0110" => ansi_char <= x"2A"; -- '*'
            when "0111" => ansi_char <= x"23"; -- '#'
            when "1000" => ansi_char <= x"25"; -- '%'
            when "1001" => ansi_char <= x"40"; -- '@' (Bright)
            when "1010" => ansi_char <= x"30"; -- '0'
            when "1011" => ansi_char <= x"31"; -- '1'
            when "1100" => ansi_char <= x"32"; -- '2'
            when "1101" => ansi_char <= x"33"; -- '3'
            when "1110" => ansi_char <= x"34"; -- '4'
            when "1111" => ansi_char <= x"57"; -- 'W' (Full intensity)
            when others => ansi_char <= x"20";
        end case;
    end process;

end architecture behavioral;