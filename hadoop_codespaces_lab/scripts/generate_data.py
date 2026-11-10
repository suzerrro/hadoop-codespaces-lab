#!/usr/bin/env python3
"""실습용 가상 주문 데이터 120,000행을 결정적으로 생성합니다 (외부 라이브러리 불필요)."""
from pathlib import Path
import csv
import random

root = Path(__file__).resolve().parents[1]
out = root / 'data' / 'orders.csv'
rng = random.Random(20261102)
cities = ['Seoul', 'Busan', 'Incheon', 'Daegu', 'Daejeon', 'Gwangju']
products = ['book', 'laptop', 'mouse', 'keyboard', 'monitor', 'headset']
statuses = ['paid', 'paid', 'paid', 'cancelled']

with out.open('w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['order_id', 'date', 'city', 'product', 'amount', 'status'])
    for order_id in range(1, 120001):
        writer.writerow([
            f'OD{order_id:07d}',
            f'2026-10-{rng.randint(1, 28):02d}',
            rng.choice(cities),
            rng.choice(products),
            rng.randrange(10, 1001) * 100,
            rng.choice(statuses),
        ])
print(f'Created: {out}')
print(f'Bytes: {out.stat().st_size:,} (Block size: 1,048,576 bytes)')
