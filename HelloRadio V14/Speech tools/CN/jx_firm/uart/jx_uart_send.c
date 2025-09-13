#include "jx_uart_send.h"

// UART1_RX串口通信消息头
const unsigned char g_uart_send_head_UART1_RX[] = {
  0xaa, 0x55
};

// UART1_RX串口通信消息尾
const unsigned char g_uart_send_foot_UART1_RX[] = {
  0x55, 0xaa
};

// UART0_RX串口通信消息头
const unsigned char g_uart_send_head_UART0_RX[] = {
  0xaa, 0x55
};

// UART0_RX串口通信消息尾
const unsigned char g_uart_send_foot_UART0_RX[] = {
  0x55, 0xaa
};

// 串口发送函数实现
void _uart_send_impl(int port, unsigned char* buff, int len) {
  // TODO: 调用项目实际的串口发送函数
  /*
  int i = 0;
  unsigned char c;
  for (i = 0; i < len; i++) {
    c = buff[i];
    printf("%02X ", c);
  }
  printf("\n");
  */
}

// action: com1
void _uart_com1() {
  uart_param_t param;
  int i = 0;
  unsigned char buff[UART_SEND_MAX] = {0};
  for (i = 0; i < UART_MSG_HEAD_LEN_UART0_RX; i++) {
      buff[i + 0] = g_uart_send_head_UART0_RX[i];
  }
  buff[2] = U_MSG_com1;
  for (i = 0; i < UART_MSG_FOOT_LEN_UART0_RX; i++) {
      buff[i + 3] = g_uart_send_foot_UART0_RX[i];
  }
  _uart_send_impl(0, buff, 5);
}

