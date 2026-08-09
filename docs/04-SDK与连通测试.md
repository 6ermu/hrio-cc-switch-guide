# 04：官网 SDK 与连通测试

## 测试顺序

不要一上来就测昂贵视频模型。按下面顺序排错：

1. DNS/HTTPS 能访问。
2. Key 能通过 `/v1/models` 鉴权。
3. 复制真实模型 ID。
4. 做一次 16 token 左右的文本请求。
5. 再配置 CC Switch。
6. 最后测试图片/视频。

## 仓库自带 Python 脚本

不依赖第三方包：

```powershell
$env:HRIO_API_KEY="真实 Key"
python .\scripts\test_hrio.py --list-models
```

测试 Chat Completions：

```powershell
python .\scripts\test_hrio.py --model "MODEL_ID" --endpoint chat
```

测试 Responses：

```powershell
python .\scripts\test_hrio.py --model "MODEL_ID" --endpoint responses
```

也可用 PowerShell 包装器：

```powershell
.\scripts\test-hrio.ps1 -ListModels
.\scripts\test-hrio.ps1 -Model "MODEL_ID" -Endpoint chat
```

## cURL

模型列表：

```bash
curl "https://hrioapi.hrio.site/api/v1/models" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

Chat Completions：

```bash
curl -X POST "https://hrioapi.hrio.site/api/v1/chat/completions" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"MODEL_ID","messages":[{"role":"user","content":"只回复 OK"}],"max_tokens":16,"stream":false}'
```

Responses：

```bash
curl -X POST "https://hrioapi.hrio.site/api/v1/responses" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"MODEL_ID","input":"只回复 OK","max_output_tokens":16,"stream":false}'
```

## OpenAI Python SDK

```bash
pip install openai
```

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["HRIO_API_KEY"],
    base_url="https://hrioapi.hrio.site/api/v1",
)

models = client.models.list()
print([item.id for item in models.data])

response = client.chat.completions.create(
    model="MODEL_ID",
    messages=[{"role": "user", "content": "只回复 OK"}],
    max_tokens=16,
)
print(response.choices[0].message.content)
```

若目标模型支持 Responses，可改用 `client.responses.create(model="MODEL_ID", input="只回复 OK")`。

## OpenAI JavaScript SDK

```bash
npm install openai
```

```javascript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.HRIO_API_KEY,
  baseURL: "https://hrioapi.hrio.site/api/v1",
});

const models = await client.models.list();
console.log(models.data.map((item) => item.id));

const result = await client.chat.completions.create({
  model: "MODEL_ID",
  messages: [{ role: "user", content: "只回复 OK" }],
  max_tokens: 16,
});
console.log(result.choices[0].message.content);
```

## 如何判断成功

- `/v1/models` HTTP 200：Key、域名和基础权限正常。
- 文本请求 HTTP 200 且有输出：Key、模型、协议和路由都正常。
- `/v1/models` 成功但文本 404/400：多数是协议或模型路径不匹配。
- 两种文本协议只成功一个：在 CC Switch 选择成功的协议；Codex + Chat-only 时使用本地路由映射。

