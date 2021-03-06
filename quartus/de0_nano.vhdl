
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de0_nano is

	port
	(
		clk       : in std_logic;
		
		DRAM_ADDR                      	: out   	std_logic_vector(12 downto 0);                    -- addr
		DRAM_BA                        	: out   	std_logic_vector(1 downto 0);                     -- ba
		DRAM_CAS_N                     	: out   	std_logic;                                        -- cas_n
		DRAM_CKE                       	: out   	std_logic;                                        -- cke
		DRAM_CS_N                     	: out   	std_logic;                                        -- cs_n
		DRAM_DQ                        	: inout 	std_logic_vector(31 downto 0) := (others => 'X'); -- dq
		DRAM_DQM                       	: out   	std_logic_vector(3 downto 0);                     -- dqm
		DRAM_RAS_N                     	: out   	std_logic;                                        -- ras_n
		DRAM_WE_N                      	: out   	std_logic;                                        -- we_n
		DRAM_CLK                       	: out   	std_logic;                                         -- clk
		
		buttons   : in std_logic_vector(1 downto 0);
--		leds      : out std_logic_vector(7 downto 0)		
		SD_CMD 	 : inout std_logic;
		SD_DAT0    : inout std_logic;
		SD_DAT3   : inout std_logic;
		SD_CLK  : out std_logic;
		AUD_ADCLRCK :in std_logic;
		AUD_ADCDAT :in std_logic;
		AUD_DACLRCK :in std_logic;
		AUD_DACDAT : out std_logic;
		AUD_BCLK :in std_logic;	
		I2C_SDAT : inout std_logic;
		I2C_SCLK : out std_logic;
		AUD_MCLK : out std_logic;
		-- display
		ltm_r                           : out   std_logic_vector(7 downto 0);
		ltm_g                           : out   std_logic_vector(7 downto 0);
		ltm_b                           : out   std_logic_vector(7 downto 0);
		ltm_den                         : out   std_logic;                                        -- vid_datavalid
		ltm_vd                          : out   std_logic;                                        -- vid_v_sync
		ltm_hd                          : out   std_logic;                                        -- vid_h_sync                                        -- vid_v
		ltm_clk                         : out   std_logic;
		ltm_rst                         : out   std_logic

	);

end entity;

architecture arch of de0_nano is

    component de0_nano_nios2 is
        port (
				clk_clk       : in  std_logic                    := 'X'; -- clk
				reset_reset_n : in  std_logic                    := 'X'; -- reset_n
				
				sdram_addr                      	: out   	std_logic_vector(12 downto 0);                    -- addr
            sdram_ba                        	: out   	std_logic_vector(1 downto 0);                     -- ba
            sdram_cas_n                     	: out   	std_logic;                                        -- cas_n
            sdram_cke                       	: out   	std_logic;                                        -- cke
            sdram_cs_n                      	: out   	std_logic;                                        -- cs_n
            sdram_dq                        	: inout 	std_logic_vector(31 downto 0) := (others => 'X'); -- dq
            sdram_dqm                       	: out   	std_logic_vector(3 downto 0);                     -- dqm
            sdram_ras_n                     	: out   	std_logic;                                        -- ras_n
            sdram_we_n                      	: out   	std_logic;                                        -- we_n
            sdram_clk_clk                   	: out   	std_logic;                                        -- clk
--				inputs_button : in  std_logic                    := 'X'; -- button
--				outputs_leds  : out std_logic_vector(7 downto 0)         -- leds

				sd_pins_b_SD_cmd : inout std_logic;
				sd_pins_b_SD_dat : inout std_logic;
				sd_pins_b_SD_dat3 : inout std_logic;
				sd_pins_o_SD_clock : out std_logic;
				
				audio_ext_interface_ADCDAT : in std_logic;
				audio_ext_interface_ADCLRCK : in std_logic;
				audio_ext_interface_BCLK : in std_logic;
				audio_ext_interface_DACDAT : out std_logic;
				audio_ext_interface_DACLRCK : in std_logic;
				audio_config_SDAT : inout std_logic;
				audio_config_SCLK : out std_logic;
				audio_mclk_clk : out std_logic;                                      
				-- display
            ltm_vid_data                    : out   std_logic_vector(23 downto 0);                    -- vid_data
            ltm_underflow                   : out   std_logic;                                        -- underflow
            ltm_vid_datavalid               : out   std_logic;                                        -- vid_datavalid
            ltm_vid_v_sync                  : out   std_logic;                                        -- vid_v_sync
            ltm_vid_h_sync                  : out   std_logic;                                        -- vid_h_sync
            ltm_vid_f                       : out   std_logic;                                        -- vid_f
            ltm_vid_h                       : out   std_logic;                                        -- vid_h
            ltm_vid_v                       : out   std_logic;                                        -- vid_v
            display_clk                     : out   std_logic                                         -- clk
        );
    end component ;
	 
	signal ltm_vd_int : std_logic;
	signal ltm_hd_int : std_logic;
	signal ltm_data : std_logic_vector(23 downto 0);
	
begin

    u0 : component de0_nano_nios2
        port map (
            clk_clk       => clk,
            reset_reset_n => buttons(0),
				
				sdram_addr                      	=> DRAM_ADDR,                      --                    sdram.addr
            sdram_ba                        	=> DRAM_BA,                        --                         .ba
            sdram_cas_n                     	=> DRAM_CAS_N,                     --                         .cas_n
            sdram_cke                       	=> DRAM_CKE,                       --                         .cke
            sdram_cs_n                      	=> DRAM_CS_N,                      --                         .cs_n
            sdram_dq                        	=> DRAM_DQ,                        --                         .dq
            sdram_dqm                       	=> DRAM_DQM,                       --                         .dqm
            sdram_ras_n                     	=> DRAM_RAS_N,                     --                         .ras_n
            sdram_we_n                      	=> DRAM_WE_N,                      --                         .we_n
            sdram_clk_clk                   	=> DRAM_CLK,                        --                sdram_clk.clk
--				inputs_button => buttons(1),  -- button.button
--				outputs_leds  => leds         --   leds.leds
				sd_pins_b_SD_cmd => SD_CMD,
				sd_pins_b_SD_dat => SD_DAT0,
				sd_pins_b_SD_dat3 => SD_DAT3,
				sd_pins_o_SD_clock => SD_CLK,
				
				audio_ext_interface_ADCDAT  => AUD_ADCDAT,
				audio_ext_interface_ADCLRCK => AUD_ADCLRCK,
				audio_ext_interface_BCLK => AUD_BCLK,
				audio_ext_interface_DACDAT => AUD_DACDAT,
				audio_ext_interface_DACLRCK => AUD_DACLRCK,
				audio_config_SDAT =>I2C_SDAT,
				audio_config_SCLK => I2C_SCLK,
				audio_mclk_clk => AUD_MCLK,                      
				ltm_vid_data                    => ltm_data,                    -- vid_data
            ltm_underflow                   => open,                                        -- underflow
            ltm_vid_datavalid               => ltm_den,                                        -- vid_datavalid
            ltm_vid_v_sync                  => ltm_vd_int,                                       -- vid_v_sync
            ltm_vid_h_sync                  => ltm_hd_int,                                        -- vid_h_sync
            ltm_vid_f                       => open,                                        -- vid_f
            ltm_vid_h                       => open,                                        -- vid_h
            ltm_vid_v                       => open,				-- vid_v
				display_clk                     => ltm_clk
				);
				
			ltm_rst <= buttons(0);  
			ltm_vd <= not ltm_vd_int;
			ltm_hd <= not ltm_hd_int;


			ltm_r     <= ltm_data(7 downto 0);
			ltm_g     <= ltm_data(15 downto 8);
			ltm_b     <= ltm_data(23 downto 16);
end architecture;





