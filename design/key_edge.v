/***************************************
**基于边缘检测的按键消抖
***************************************/
module		key_edge(
	input				clk,
	input				rst_n,
	input				key,								//按键
	output				key_negedge,						//按键下降沿
	output	reg			key_come							//按键尖峰脉冲输出
);					
					
	reg			key_r;										//键值寄存器
	reg			state;										//延时计数状态寄存器
	reg			state_pos;									//尖峰脉冲状态寄存器
	reg	[15:0]	cnt;										//计数器

//----------------按键下降沿检测-------------------------	
always	@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)
			begin
				key_r	<=	1'b1;
			end
		else
			begin
				key_r	<=	key;
			end
	end
		
assign	key_negedge	=	key_r	&	(~key);					//按键下降沿出现以后置高一个周期

//--------------延时计数-----------------------------
always	@(posedge clk	or	negedge	rst_n)
	begin
		if(!rst_n)
			begin
				cnt		<=	0;
				state	<=	0;
			end
		else
			case(state)
				0:	begin
						if(key_negedge)						//首次检测到下降沿
							begin
								state	<=	1;				//状态向下跳 转
							end
					end
				1:	begin
						if(key_negedge)						//再次检测到下降沿（说明有抖动）
							begin
								cnt		<=	0;				//计数器复位
								state	<=	0;				//状态返回
							end
						else
							begin
								if(cnt	<	999)			//延时时间未到
									begin
										cnt		<=	cnt	+1'b1;
									end
								else						//延时时间到了（满足条件）
									begin
										cnt		<=	0;		//计数器清零
										state	<=	0;		//状态复位。等待下次检测
									end
							end
					end
				default:	state	<=	0;
			endcase
	end

//------------尖峰脉冲输出------------------------------------
always	@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)
			begin
				state_pos	<=	0;
				key_come	<=	0;
			end
		else
			begin
				case(state_pos)
					0:	begin
							if(cnt	==	999)				//计数时间满
								begin
									state_pos	<=	1;		//跳转到下一个状态
									key_come	<=	1;		//输出一个周期脉冲
								end
						end
					1:	begin
							state_pos	<=	0;				//跳转到0状态
							key_come	<=	0;				//输出拉低
						end
					default:	state_pos	<=	0;			//默认为0状态
				endcase
			end
	end

endmodule