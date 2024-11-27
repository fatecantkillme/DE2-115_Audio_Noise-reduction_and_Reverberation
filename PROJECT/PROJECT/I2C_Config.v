module I2C_Config (
	CLK,
	RST,
	getinmode,
	I2C_SCLK,
	I2C_SDAT	);

input		CLK;
input		RST;
input   getinmode;

//I2C
output		I2C_SCLK;
inout		I2C_SDAT;

reg	[15:0]	mI2C_CLK_DIV;
reg	[23:0]	mI2C_DATA;
reg			mI2C_CTRL_CLK;
reg			mI2C_GO;
wire		mI2C_END;
wire		mI2C_ACK;
reg	[15:0]	LUT_DATA;
reg	[5:0]	LUT_INDEX;
reg	[3:0]	mSetup_ST;

//	Clock Frequency
parameter	CLK_Freq		=	50000000;	//	50	MHz
parameter	I2C_Freq		=	20000;		//	20	KHz

parameter	LUT_SIZE		=	51;			

parameter	Dummy_DATA	=	0;
parameter	SET_LIN_L	=	1;
parameter	SET_LIN_R	=	2;
parameter	SET_HEAD_L	=	3;
parameter	SET_HEAD_R	=	4;
parameter	A_PATH_CTRL	=	5;
parameter	D_PATH_CTRL	=	6;
parameter	POWER_ON		=	7;
parameter	SET_FORMAT	=	8;
parameter	SAMPLE_CTRL	=	9;
parameter	SET_ACTIVE	=	10;


//I2C Clock
always@(posedge CLK or negedge RST)
begin
	if(!RST)
	begin
		mI2C_CTRL_CLK	<=	0;
		mI2C_CLK_DIV	<=	0;
	end
	else
	begin
		if( mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq) )
			mI2C_CLK_DIV	<=	mI2C_CLK_DIV + 1'b1;
		else
		begin
			mI2C_CLK_DIV	<=	0;
			mI2C_CTRL_CLK	<=	~mI2C_CTRL_CLK;
		end
	end
end

I2C_Controller	inst5(	
		.CLOCK(mI2C_CTRL_CLK),	
		.I2C_SCLK(I2C_SCLK),				
 	 	.I2C_SDAT(I2C_SDAT),			
		.I2C_DATA(mI2C_DATA),		
		.GO(mI2C_GO),      			
		.END(mI2C_END),				 
		.ACK(mI2C_ACK),				
		.RESET(RST)	
);

//Initialization sequence 
always@(posedge mI2C_CTRL_CLK or negedge RST)
begin
	if(!RST)
	begin
		LUT_INDEX	<=	0;
		mSetup_ST	<=	0;
		mI2C_GO		<=	0;
	end
	else
	begin
		if(LUT_INDEX < LUT_SIZE)
		begin
			case(mSetup_ST)
			0:	
			begin
				if(LUT_INDEX <= SET_ACTIVE)
					mI2C_DATA	<=	{8'h34,LUT_DATA};
				else
					mI2C_DATA	<=	{8'h40,LUT_DATA};
				mI2C_GO		<=	1;
				mSetup_ST	<=	1;
			end
			1:	
			begin
				if(mI2C_END)
				begin
					if(!mI2C_ACK)
						mSetup_ST	<=	2;
					else
						mSetup_ST	<=	0;							
					mI2C_GO			<=	0;
				end
			end
			2:	
			begin
				LUT_INDEX	<=	LUT_INDEX + 1'b1;
				mSetup_ST	<=	0;
			end
			endcase
		end
	end
end


//Initialize CODEC 
always
begin
if(getinmode==0)
begin
	case(LUT_INDEX)
	Dummy_DATA	:	LUT_DATA	<=	16'h0000;
	SET_LIN_L	:	LUT_DATA	<=	16'h001A; 		//左声道输入
	SET_LIN_R	:	LUT_DATA	<=	16'h021A; 		// 右声道输入
	SET_HEAD_L	:	LUT_DATA	<=	16'h047B; 		// 左声道输出
	SET_HEAD_R	:	LUT_DATA	<=	16'h067B; 		// 右声道输出
	A_PATH_CTRL	:	LUT_DATA	<=	16'h0812;		// 开启ADC，dac
	D_PATH_CTRL	:	LUT_DATA	<=	16'h0A06; 		// 48khz
	POWER_ON	:		LUT_DATA	<=	16'h0C00; 		// all on 
	SET_FORMAT	:	LUT_DATA	<=	16'h0E01; 		//作为从属
	SAMPLE_CTRL	:	LUT_DATA	<=	16'h1002; 		//作为从属
	SET_ACTIVE	:	LUT_DATA	<=	16'h1201; 		//使能
	default:			LUT_DATA	<=	16'h0000;
	endcase
end
else
begin
	case(LUT_INDEX)
	Dummy_DATA	:	LUT_DATA	<=	16'h0000;
	SET_LIN_L	:	LUT_DATA	<=	16'h001A; 		// 左声道输入
	SET_LIN_R	:	LUT_DATA	<=	16'h021A; 		// 右声道输入
	SET_HEAD_L	:	LUT_DATA	<=	16'h047B; 		// 左声道输出
	SET_HEAD_R	:	LUT_DATA	<=	16'h067B; 		// 右声道输出
	A_PATH_CTRL	:	LUT_DATA	<=	16'h0815;		// 开启ADC，dac
	D_PATH_CTRL	:	LUT_DATA	<=	16'h0A06; 		// 48khz
	POWER_ON	:		LUT_DATA	<=	16'h0C00; 		// all on 
	SET_FORMAT	:	LUT_DATA	<=	16'h0E01; 		//作为从属
	SAMPLE_CTRL	:	LUT_DATA	<=	16'h1002; 		//作为从属
	SET_ACTIVE	:	LUT_DATA	<=	16'h1201; 		//使能
	default:			LUT_DATA	<=	16'h0000;
	endcase
end
end


endmodule