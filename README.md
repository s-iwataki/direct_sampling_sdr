# Direct Sampling SDR

14ビットADC/DACをフロントエンドとするダイレクトサンプリング方式のソフトウェア無線機(SDR)のFPGA実装。

## システム構成

```
                        FPGA (MAX 10)
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   [受信パス]                                                    │
│   ADC ──→ NCO ──→ CIC ──→ FIR ──→ I2S TX ──→ 外部DSP          │
│   14bit   Mix    ÷256   ÷10      I/Q出力                       │
│   122.88MHz              48kHz                                  │
│                                                                 │
│   [送信パス]                                                    │
│   外部DSP ──→ I2S RX ──→ FIR ──→ CIC ──→ NCO ──→ DAC          │
│              I/Q入力     ×10    ×256    Mix    14bit           │
│              48kHz                      122.88MHz               │
│                                                                 │
│   [制御]                                                        │
│   SPI ──→ コントロールレジスタ ──→ 周波数設定/FIR係数/ゲイン   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 仕様

| 項目 | 仕様 |
|------|------|
| RF ADC/DAC | 14ビット @ 122.88 MHz |
| ベースバンドサンプルレート | 48 kHz |
| デシメーション/インターポレーション比 | 2560:1 (CIC 256× + FIR 10×) |
| I2Sフォーマット | 16ビット ステレオ (I/Q) @ 48 kHz |
| NCO分解能 | 27ビット位相アキュムレータ |
| FIRフィルタ | 256タップ、係数可変 |
| ターゲットFPGA | Intel MAX 10 (10M08DAF484C8GES) |

## モジュール構成

### 信号処理
- `nco.v` - NCO (ルックアップテーブル + 加法定理による補間)
- `cic_decimator.v` - 4段CICデシメータ (÷256)
- `cic_interpolator.v` - 4段CICインターポレータ (×256)
- `fir_decimator.v` - 256タップFIRデシメータ (÷10)
- `fir_interpolator.v` - 256タップFIRインターポレータ (×10)

### インターフェース
- `i2s_interface.v` - I2S送受信
- `i2s_timing_generator.v` - I2Sクロック生成 (BCLK: 1.536 MHz, WS: 48 kHz)
- `spi_interface.v` - SPI受信 (制御コマンド用)
- `control_registers.v` - コマンド解釈・レジスタ管理

### タイミング
- `timing_generator.v` - 内部タイミング信号生成 (÷256, ÷2560)

## ビルド

Intel Quartus Prime Lite Edition v22.1以降が必要。

```bash
# GUIで開く
quartus direct_sampling_sdr.qpf

# コマンドラインでコンパイル
quartus_sh --flow compile direct_sampling_sdr
```

## 開発状況

現在実装中。トップモジュール(`direct_sampling_sdr.v`)は各モジュールのコンパイル確認用の暫定記述。

## ライセンス

（未定）
