- POST /cart - Without session

Payload

- product_id: id do produto a ser adicionado
- quantity: quantidade de produto a ser adicionado

Exemplo de requisição:

```
 curl -X POST http://localhost:3000/cart \
  -H 'Content-Type: application/json' \
  -d '{"product_id":"65", "quantity":"1" }' \
  -v
```

Exemplo de retorno:

```
{
  "cart": {
    "items": [
      {
        "product_id": 1,
        "quantity": 1
      }
    ]
  }
}
```


POST /cart - With session

Payload

- product_id: id do produto a ser adicionado
- quantity: quantidade de produto a ser adicionado
- session: token de sessão (use curl -v ou inspect do navegador para pegar o
  token)


Exemplo de requisição:

```
 curl -X POST http://localhost:3000/cart \
  -H 'Content-Type: application/json' \
  -H 'Cookie: _store_session=42e5bfb2731a793e39902780bba275a2; path=/; httponly' \
  -d '{"product_id":"2", "quantity":"2" }' \
  -v
```

Exemplo de retorno:

```
{
  "cart": {
    "items": [
      {
        "product_id": 1,
        "quantity": 1
      }
    ]
  }
}
```


GET /cart - With session

Payload

- product_id: id do produto a ser adicionado
- quantity: quantidade de produto a ser adicionado
- session: token de sessão (use curl -v ou inspect do navegador para pegar o
  token)


Exemplo de requisição:

```
 curl http://localhost:3000/cart \
  -H 'Content-Type: application/json' \
  -H 'Cookie: _store_session=42e5bfb2731a793e39902780bba275a2; path=/; httponly' \
  -v
```

Exemplo de retorno:

```
{
  "cart": {
    "items": [
      {
        "product_id": 1,
        "quantity": 1
      }
    ]
  }
}
```
