
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"0c",x"04",x"06",x"05"),
     1 => (x"0a",x"83",x"0b",x"03"),
     2 => (x"00",x"07",x"00",x"66"),
     3 => (x"00",x"da",x"00",x"5a"),
     4 => (x"08",x"94",x"80",x"00"),
     5 => (x"00",x"07",x"80",x"05"),
     6 => (x"00",x"01",x"80",x"02"),
     7 => (x"00",x"09",x"80",x"03"),
     8 => (x"00",x"78",x"80",x"04"),
     9 => (x"08",x"91",x"80",x"01"),
    10 => (x"00",x"00",x"00",x"26"),
    11 => (x"00",x"00",x"00",x"1d"),
    12 => (x"00",x"00",x"00",x"1c"),
    13 => (x"00",x"00",x"00",x"25"),
    14 => (x"00",x"00",x"00",x"1a"),
    15 => (x"00",x"00",x"00",x"1b"),
    16 => (x"00",x"00",x"00",x"24"),
    17 => (x"00",x"00",x"01",x"12"),
    18 => (x"00",x"00",x"00",x"2e"),
    19 => (x"00",x"00",x"00",x"2d"),
    20 => (x"00",x"00",x"00",x"23"),
    21 => (x"00",x"00",x"00",x"36"),
    22 => (x"00",x"00",x"00",x"21"),
    23 => (x"00",x"00",x"00",x"2b"),
    24 => (x"00",x"00",x"00",x"2c"),
    25 => (x"00",x"00",x"00",x"22"),
    26 => (x"00",x"6c",x"00",x"3d"),
    27 => (x"00",x"00",x"00",x"35"),
    28 => (x"00",x"00",x"00",x"34"),
    29 => (x"00",x"75",x"00",x"3e"),
    30 => (x"00",x"00",x"00",x"32"),
    31 => (x"00",x"00",x"00",x"33"),
    32 => (x"00",x"6b",x"00",x"3c"),
    33 => (x"00",x"00",x"00",x"2a"),
    34 => (x"00",x"7d",x"00",x"46"),
    35 => (x"00",x"73",x"00",x"43"),
    36 => (x"00",x"69",x"00",x"3b"),
    37 => (x"00",x"ca",x"00",x"45"),
    38 => (x"00",x"70",x"00",x"3a"),
    39 => (x"00",x"72",x"00",x"42"),
    40 => (x"00",x"74",x"00",x"44"),
    41 => (x"00",x"00",x"00",x"31"),
    42 => (x"00",x"78",x"00",x"55"),
    43 => (x"00",x"7c",x"00",x"4d"),
    44 => (x"00",x"7a",x"00",x"4b"),
    45 => (x"00",x"7e",x"00",x"7b"),
    46 => (x"00",x"71",x"00",x"49"),
    47 => (x"00",x"84",x"00",x"4c"),
    48 => (x"00",x"77",x"00",x"54"),
    49 => (x"00",x"00",x"00",x"41"),
    50 => (x"00",x"fc",x"00",x"61"),
    51 => (x"00",x"7c",x"00",x"5b"),
    52 => (x"00",x"00",x"00",x"52"),
    53 => (x"00",x"78",x"00",x"f1"),
    54 => (x"00",x"00",x"02",x"59"),
    55 => (x"00",x"5d",x"00",x"0e"),
    56 => (x"00",x"00",x"00",x"5d"),
    57 => (x"00",x"79",x"00",x"4a"),
    58 => (x"00",x"00",x"00",x"16"),
    59 => (x"00",x"fc",x"00",x"76"),
    60 => (x"00",x"0d",x"04",x"14"),
    61 => (x"00",x"00",x"00",x"1e"),
    62 => (x"00",x"00",x"00",x"29"),
    63 => (x"00",x"00",x"00",x"11"),
    64 => (x"00",x"00",x"00",x"15"),
    65 => (x"00",x"00",x"40",x"00"),
    66 => (x"00",x"00",x"41",x"10"),
    67 => (x"00",x"00",x"41",x"a5"),
    68 => (x"3b",x"63",x"72",x"41"),
    69 => (x"3b",x"4d",x"4f",x"52"),
    70 => (x"2c",x"55",x"30",x"53"),
    71 => (x"2c",x"46",x"44",x"41"),
    72 => (x"70",x"6f",x"6c",x"46"),
    73 => (x"31",x"20",x"79",x"70"),
    74 => (x"31",x"53",x"3b",x"3a"),
    75 => (x"44",x"41",x"2c",x"55"),
    76 => (x"6c",x"46",x"2c",x"46"),
    77 => (x"79",x"70",x"70",x"6f"),
    78 => (x"3b",x"3a",x"32",x"20"),
    79 => (x"2c",x"55",x"32",x"53"),
    80 => (x"2c",x"46",x"44",x"48"),
    81 => (x"64",x"72",x"61",x"48"),
    82 => (x"73",x"69",x"64",x"20"),
    83 => (x"3a",x"31",x"20",x"6b"),
    84 => (x"55",x"33",x"53",x"3b"),
    85 => (x"46",x"44",x"48",x"2c"),
    86 => (x"72",x"61",x"48",x"2c"),
    87 => (x"69",x"64",x"20",x"64"),
    88 => (x"32",x"20",x"6b",x"73"),
    89 => (x"52",x"53",x"3b",x"3a"),
    90 => (x"41",x"52",x"2c",x"55"),
    91 => (x"6f",x"4c",x"2c",x"4d"),
    92 => (x"43",x"20",x"64",x"61"),
    93 => (x"20",x"53",x"4f",x"4d"),
    94 => (x"3a",x"4d",x"41",x"52"),
    95 => (x"55",x"53",x"53",x"3b"),
    96 => (x"4d",x"41",x"52",x"2c"),
    97 => (x"76",x"61",x"53",x"2c"),
    98 => (x"4d",x"43",x"20",x"65"),
    99 => (x"52",x"20",x"53",x"4f"),
   100 => (x"3b",x"3a",x"4d",x"41"),
   101 => (x"52",x"2c",x"31",x"54"),
   102 => (x"74",x"65",x"73",x"65"),
   103 => (x"76",x"2c",x"56",x"3b"),
   104 => (x"2e",x"30",x"2e",x"31"),
   105 => (x"53",x"49",x"52",x"00"),
   106 => (x"20",x"53",x"4f",x"43"),
   107 => (x"4d",x"4f",x"52",x"20"),
   108 => (x"4d",x"4f",x"52",x"00"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

