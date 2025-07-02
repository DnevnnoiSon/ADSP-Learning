# 🔘 Blackfin DSP Assembly Learning Project [![Project Status](https://img.shields.io/badge/status-archived-lightgrey)](https://shields.io/)

## 💡 О проекте
#### **Учебный Проект** для погружения в архитектуру многоядерных DSP-процессоров от Analog Devices Blackfin. Весь код написан **на чистом ассемблере**. Проект является сугубо демонстративной штукой.

---
## ⚙️ Реализованный функционал
#### 🟢 Джиттер 
#### 🟢 Управление синтезатором
#### 🟢 Настройка остальной переферии

---
## ⚙️ Примечание
#### Реализовано в соответствии с соглашением о вызовах - [ являются совместимыми с С\С++ ]
#### Отсутствует поддержка аппаратно-зависимых модулей.
#### Модуль <code style="color:#79c0ff;">[asm_def.h]</code> - знакомит с базовыми алгоритмами и приемами языка Assembler.

---
## ⚙️ Ключевые модули

<div style="background-color:#0d1117; color:#c9d1d9; padding:16px; border-radius:6px; font-family:Segoe UI, sans-serif;">

<table style="width:100%; border-collapse:collapse;">
  <thead>
    <tr>
      <th style="text-align:center; border-bottom:1px solid #30363d; padding:8px;">Описание:</th>
      <th style="text-align:center; border-bottom:1px solid #30363d; padding:8px;">Модули:</th>
      <th style="text-align:left;   border-bottom:1px solid #30363d; padding:8px;">Функционал:</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:center; padding:8px;">⏱️ <br><b>Системное тактирование</b></td>
      <td style="text-align:center; padding:8px;"><code style="color:#79c0ff;">[SystClock.asm]</code></td>
      <td style="padding:8px;">Настройка CGU/PLL для управления частотой ядра</td>
    </tr>
    <tr>
      <td style="text-align:center; padding:8px;">🔌 <br><b>GPIO</b></td>
      <td style="text-align:center; padding:8px;"><code style="color:#79c0ff;">[gpio.asm]</code></td>
      <td style="padding:8px;">Управление пинами (ввод/вывод, переключение состояний)</td>
    </tr>
    <tr>
      <td style="text-align:center; padding:8px;">⚠️ <br><b>Прерывания</b></td>
      <td style="text-align:center; padding:8px;"><code style="color:#79c0ff;">[sec.asm]</code>, <code style="color:#79c0ff;">[trigger.asm]</code></td>
      <td style="padding:8px;">Диспетчеризация событий (SEC) + обработка внешних прерываний (PINT)</td>
    </tr>
    <tr>
      <td style="text-align:center; padding:8px;">⏲️ <br><b>Таймеры</b></td>
      <td style="text-align:center; padding:8px;"><code style="color:#79c0ff;">[timer.asm]</code></td>
      <td style="padding:8px;">Генерация периодических прерываний</td>
    </tr>
    <tr>
      <td style="text-align:center; padding:8px;">📡 <br><b>SPORT (SPI)</b></td>
      <td style="text-align:center; padding:8px;"><code style="color:#79c0ff;">[sport.asm]</code></td>
      <td style="padding:8px;">Конфигурация порта + передача 24-битных данных</td>
    </tr>
    <tr>
      <td style="text-align:center; padding:8px;">🎛️ <br><b>Синтезатор</b></td>
      <td style="text-align:center; padding:8px;"><code style="color:#79c0ff;">[lmx2571.asm]</code></td>
      <td style="padding:8px;">Инициализация и программирование LMX2571 через SPI</td>
    </tr>
  </tbody>
</table>

</div>

---

## 📚 Полезные ссылки
#### 1. Официальная документация Blackfin: [Blackfin](https://www.analog.com/en/product-category/blackfin-embedded-processors.html)

#### 2. ADSP-BF637 Processor Hardware Reference: [DSP_Hardware](https://www.analog.com/en/products/adsp-bf706.html)

#### 3. LMX2571 Datasheet: [LMX2571](https://www.ti.com/product/LMX2571?utm_source=google&utm_medium=cpc&utm_campaign=asc-null-null-GPN_EN-cpc-pf-google-ww_en_cons&utm_content=LMX2571&ds_k=LMX2571+Datasheet&DCM=yes&gad_source=1&gad_campaignid=14388345080&gbraid=0AAAAAC068F0tDwg2GOt8zBu7KQcb4JbMF&gclid=CjwKCAjwsZPDBhBWEiwADuO6y6le7VWeU7hos0-ozwdlVbH3oU6Lvj5CQ_Wrc5Ne2-IxML7uOQ6j8xoCNfcQAvD_BwE&gclsrc=aw.ds)


