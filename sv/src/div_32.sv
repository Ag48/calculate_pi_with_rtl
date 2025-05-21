module div_32 #(
    parameter P_WIDTH = 32
) (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 start,
    input  logic [P_WIDTH-1:0]     dividend_in,
    input  logic [P_WIDTH-1:0]     divisor_in,
    output logic [P_WIDTH-1:0]     quotient_out,
    output logic [P_WIDTH-1:0]     remainder_out,
    output logic                 done
);

// States for the Finite State Machine
typedef enum logic [1:0] {
    IDLE,       // 待機状態
    CALC,       // 計算実行中
    POST_CALC,  // 計算後の剰余調整
    FINISH      // 完了通知状態
} state_t;

state_t current_state, next_state;

// Internal Registers
logic [P_WIDTH:0]         A_reg;     // アキュムレータ (P_WIDTH+1 ビット)
logic [P_WIDTH-1:0]       Q_reg;     // 被除数、その後、商を格納
logic [P_WIDTH:0]         M_reg;     // 除数 (P_WIDTH+1 ビット, {0, divisor_in})
logic [$clog2(P_WIDTH+1)-1:0] count_reg; // ループカウンタ (0 から P_WIDTH まで表現可能)

logic done_internal;
logic A_prev_sign;
logic Q_msb;

assign A_prev_sign = A_reg[P_WIDTH];     // 前回のAの符号
assign Q_msb = Q_reg[P_WIDTH-1];         // 現在のQのMSB

// ステップ1: AとQを結合して左シフト
logic [P_WIDTH:0]   A_shifted_current;
logic [P_WIDTH-1:0] Q_next_shifted_part;
assign A_shifted_current = {A_reg[P_WIDTH-1:0], Q_msb};
assign  Q_next_shifted_part = Q_reg << 1;

// ステップ2: 前回のAの符号に基づいて加算または減算
logic [P_WIDTH:0] A_op_result_current;


// Combinational logic for next state and done signal
always_comb begin
    next_state = current_state;
    done_internal = 1'b0;

    case (current_state)
        IDLE: begin
            if (start) begin
                if (divisor_in == 0) begin // ゼロ除算チェック
                    next_state = FINISH;    // エラー処理へ
                end else begin
                    next_state = CALC;      // 通常の計算開始
                end
            end
        end
        CALC: begin
            if (count_reg == 0) begin
                next_state = POST_CALC; // 計算ループ終了
            end else begin
                next_state = CALC;      // 計算継続
            end
        end
        POST_CALC: begin
            next_state = FINISH;        // 剰余調整完了、完了通知へ
        end
        FINISH: begin
            done_internal = 1'b1;       // done信号をアサート
            next_state = IDLE;          // 待機状態へ戻る
        end
        default: next_state = IDLE;
    endcase
end

// Sequential logic for state transitions and register updates
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // 非同期リセット
        current_state <= IDLE;
        A_reg         <= '0;
        Q_reg         <= '0;
        M_reg         <= '0;
        count_reg     <= '0;
        quotient_out  <= '0;
        remainder_out <= '0;
        done          <= 1'b0;
    end else begin
        current_state <= next_state;
        done <= done_internal; // done信号はFINISHステートで1サイクルHigh

        // 状態遷移時のレジスタ更新
        if (current_state == IDLE && next_state == CALC) begin // 通常の計算開始時
            A_reg     <= { (P_WIDTH+1){1'b0} };    // アキュムレータ初期化
            Q_reg     <= dividend_in;            // Qに被除数をロード
            M_reg     <= {1'b0, divisor_in};     // Mに除数をロード (上位1ビットは0)
            count_reg <= P_WIDTH;                   // カウンタ初期化
            quotient_out  <= '0;                  // 出力をクリア
            remainder_out <= '0;
        end else if (current_state == IDLE && next_state == FINISH) begin // ゼロ除算時
            quotient_out  <= {P_WIDTH{1'b1}};       // 商は全ビット1
            remainder_out <= dividend_in;         // 剰余は被除数
        end

        if (current_state == CALC) begin
            if (count_reg > 0) begin
                if (A_prev_sign == 1'b0) begin // Aが正またはゼロだった場合
                    A_op_result_current = A_shifted_current - M_reg;
                end else begin // Aが負だった場合
                    A_op_result_current = A_shifted_current + M_reg;
                end

                // ステップ3: 今回の演算結果Aの符号に基づいてQのLSBを設定
                if (A_op_result_current[P_WIDTH] == 1'b0) begin // 新しいAが正またはゼロの場合
                    Q_reg <= Q_next_shifted_part | 1'b1;    // QのLSBを1に
                end else begin // 新しいAが負の場合
                    Q_reg <= Q_next_shifted_part;           // QのLSBは0 (シフトで既に0)
                end
                A_reg <= A_op_result_current;       // Aを更新
                count_reg <= count_reg - 1;         // カウンタをデクリメント
            end
        end

        if (current_state == POST_CALC) begin
            // 商はQ_regに格納されている
            quotient_out <= Q_reg;

            // 剰余の最終調整
            if (A_reg[P_WIDTH] == 1'b1) begin // 最終的なAが負の場合
                // remainder_out <= (A_reg + M_reg)[P_WIDTH-1:0]; // A = A + M で補正
                remainder_out <= A_reg + M_reg; // A = A + M で補正
            end else begin
                remainder_out <= A_reg[P_WIDTH-1:0]; // Aが正ならそのまま剰余
            end
        end
    end
end

endmodule
