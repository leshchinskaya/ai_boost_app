// otp_auth_machine.ts
import { createMachine, assign } from 'xstate';

interface AuthContext {
  phoneNumber: string;
  otp: string;
  attempts: number;
  error?: string;
}

type AuthEvent =
  | { type: 'SUBMIT_PHONE'; phone: string }
  | { type: 'CODE_SENT' }
  | { type: 'SUBMIT_OTP'; otp: string }
  | { type: 'OTP_VERIFIED' }
  | { type: 'OTP_FAILED'; error: string }
  | { type: 'RESEND_CODE' }
  | { type: 'LOGOUT' };

export const authMachine = createMachine<AuthContext, AuthEvent>(
  {
    id: 'otpAuth',
    initial: 'enterPhone',
    context: {
      phoneNumber: '',
      otp: '',
      attempts: 0,
      error: undefined,
    },
    states: {
      enterPhone: {
        meta: { widget: 'PhoneInputScreen' },
        on: {
          SUBMIT_PHONE: {
            target: 'sendingCode',
            cond: 'isValidPhone',
            actions: ['assignPhone', 'clearError'],
          },
        },
      },

      sendingCode: {
        meta: { widget: 'ProgressScreen' },
        invoke: {
          id: 'sendOtp',
          src: 'sendOtp',
          onDone: { target: 'enterOtp', actions: 'clearError' },
          onError: { target: 'error', actions: 'setError' },
        },
        on: {
          RESEND_CODE: {
            target: 'sendingCode',
            actions: 'clearError',
          },
        },
      },

      enterOtp: {
        meta: { widget: 'OtpInputScreen' },
        on: {
          SUBMIT_OTP: [
            {
              target: 'verifyingOtp',
              cond: 'isValidOtp',
              actions: ['assignOtp', 'clearError'],
            },
            {
              target: 'error',
              actions: assign({ error: (_ctx, _evt) => 'Неверный формат кода' }),
            },
          ],
        },
      },

      verifyingOtp: {
        meta: { widget: 'ProgressScreen' },
        invoke: {
          id: 'verifyOtp',
          src: 'verifyOtp',
          onDone: { target: 'authenticated', actions: 'clearError' },
          onError: {
            target: 'error',
            actions: ['incrementAttempts', 'setError'],
          },
        },
      },

      authenticated: {
        meta: { widget: 'HomeScreen' },
        on: {
          LOGOUT: { target: 'enterPhone', actions: 'clearError' },
        },
      },

      error: {
        meta: { widget: 'ErrorScreen' },
        on: {
          RESEND_CODE: { target: 'sendingCode', actions: 'clearError' },
          SUBMIT_PHONE: { target: 'sendingCode', cond: 'isValidPhone', actions: ['assignPhone', 'clearError'] },
          SUBMIT_OTP: {
            target: 'verifyingOtp',
            cond: 'isValidOtp',
            actions: ['assignOtp', 'clearError'],
          },
          LOGOUT: { target: 'enterPhone', actions: 'clearError' },
        },
      },
    },
  },
  {
    guards: {
      isValidPhone: (_ctx, evt) =>
        evt.type === 'SUBMIT_PHONE' && /^\+\d{10,15}$/.test(evt.phone),
      isValidOtp: (_ctx, evt) =>
        evt.type === 'SUBMIT_OTP' && /^\d{4,8}$/.test(evt.otp),
    },
    actions: {
      assignPhone: assign({
        phoneNumber: (_ctx, evt) => (evt.type === 'SUBMIT_PHONE' ? evt.phone : ''),
      }),
      assignOtp: assign({
        otp: (_ctx, evt) => (evt.type === 'SUBMIT_OTP' ? evt.otp : ''),
      }),
      incrementAttempts: assign({
        attempts: (ctx) => ctx.attempts + 1,
      }),
      setError: assign({
        error: (_ctx, evt) =>
          evt.type === 'OTP_FAILED' ? evt.error : 'Не удалось выполнить операцию',
      }),
      clearError: assign({
        error: (_ctx, _evt) => undefined,
      }),
    },
    services: {
      /** Мокаемая отправка SMS. В продакшене замените своим API-вызовом. */
      sendOtp: (ctx) =>
        new Promise((resolve, reject) => {
          // имитация 500 мс сетевой задержки
          setTimeout(() => {
            // простой псевдо-рандом: 90 % успех, 10 % ошибка
            Math.random() < 0.9 ? resolve(ctx.phoneNumber) : reject(new Error('Сервис SMS недоступен'));
          }, 500);
        }),

      /** Мокаемая проверка OTP. Замените настоящей проверкой. */
      verifyOtp: (ctx) =>
        new Promise((resolve, reject) => {
          setTimeout(() => {
            // условие «код верен, если он заканчивается на 42»
            ctx.otp.endsWith('42')
              ? resolve(true)
              : reject(new Error('Неверный код'));
          }, 500);
        }),
    },
  },
);
