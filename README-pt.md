# Flutter Full Router (FFR)

Um motor de navegação poderoso e sem dependências, construído do zero para Flutter usando a API nativa `Router`. Esqueça bibliotecas de roteamento de terceiros complexas — o FFR te dá controle total sobre a pilha de navegação, extração de parâmetros de URL, interceptação de rotas (guards) de autenticação, rotas nomeadas dinâmicas, modais/bottom sheets customizados, **registro de rotas em tempo de execução**, e **rotas de ação**.

## Por que o FFR?

O Navigator 2.0 do Flutter (Router API) é sabidamente verboso. O FFR encapsula essa complexidade em um motor de estado reativo e limpo (`FFRNavigator`) que imita a simplicidade da navegação baseada em URL enquanto oferece funcionalidades avançadas ideais para aplicações reais.

**Principais Funcionalidades:**

- **Zero Dependências:** Escrito inteiramente em Dart/Flutter. Conecte-o diretamente no `MaterialApp.router`.
- **Acesso Global via Singleton:** Use `FFRNavigator.I` em qualquer lugar no seu app para realizar o push/pop de rotas sem precisar repassar instâncias!
- **Extração Dinâmica de URL:** O `FFRRouteParser` embutido transforma `/{id}` ou `/{username}` diretamente em Maps para os builders dos seus widgets.
- **Tipos de Rota:** Realize o push de páginas completas, `Dialog`s, `ModalBottomSheet`s, ou `Action`s diretamente via URL sem esforço. Páginas nativas do FFR (`FFRDialogPage`, `FFRBottomSheetPage`) lidam corretamente com o botão de voltar e histórico do SO.
- **Rotas de Ação:** Defina a sua lógica de negócio como uma rota (`FFRRouteType.action`). Ao navegar para ela, executa-se uma função ao invés de adicionar uma página à fila (stack). Perfeito para chamadas de API, logouts, ou gatilhos de máquina de estado.
- **Guards (Interceptores):** Um `FFRRouteGuard` centralizado permite interceptar e redirecionar fluxos (ex: redirecionar usuários não autenticados de volta para `/login`) antes mesmo da UI iniciar o processo de construção.
- **Navegação Orientada a Estado:** Ouça as mudanças do stack facilmente usando `ChangeNotifier` e acesse seu histórico de navegação completo (`FFRNavigator.I.history`) a qualquer momento.
- **Observers:** Suporte de primeira classe para `NavigatorObserver`, incluindo um `FFRRouteLogger` nativo para facilitar e limpar a visualização do debug.
- **Registro Dinâmico de Rotas:** Adicione ou remova rotas em tempo de execução sem reconstruir o navigator — perfeito para feature flags, arquitetura de plugins ou módulos carregados tardiamente (lazy loading).

## Arquitetura & Como Funciona

A arquitetura é dividida em claras responsabilidades:

1. **Definições (`FFRRouteDefinition`)**:
   Você define uma lista dessas definições. Cada definição declara seu path (caminho, ex: `/home`), seu tipo (`fullPage`, `dialog`, `bottomSheet`, ou `action`), suas restrições de fluxo (`FFROpenFlow.postLogin`), e dispõe de um `builder` (para retornar um Widget) ou um callback de `action` (para efeitos colaterais).

2. **O Parser (`FFRRouteParser`)**:
   Converte strings literais como `/post/123?ref=social` contrastando com suas definições cadastradas. Extraí `id=123` em `pathParams` e `ref=social` em `queryParams`, retornando um `FFRRouteMatch`. Rotas também podem ser adicionadas ou removidas do parser em tempo de execução.

3. **O Motor (`FFRNavigator`)**:
   O coração do sistema. Chamar `FFRNavigator.I.pushNamed('/route')` sinaliza o parser. Se combinar com o destino registrado, ele passa pela verificação do **Guard** configurado. Se o guard permitir, o engine modificará a lista interna que mantém a rota de interface (`stack`) e notifica os ouvintes (exceto caso seja uma rota de action, que por sua vez somente executa seu conteúdo e encerra).
   - **Histórico (History)**: Você poderá consultar `FFRNavigator.I.history` seguramente em qualquer trecho. Por gerenciar a navegação nativamente como pilhas, esse getter reflete perfeitamente a hierarquia atual do app!
   - **Rotas Dinâmicas**: Invoque os métodos `addRoute`, `addRoutes`, ou `removeRoute` para moldar sua tabela central a qualquer momento online.

4. **Os Delegates (`FFRRouterDelegate` & `FFRRouteInformationParser`)**:
   Elas ligam o sistema do FFR internamente e em sintonia com os artifícios `MaterialApp.router` nativo do framework Flutter. O Information Parser colhe as metadatas das URL que partilharem pela Web ou do S.O/Aplicativo e converte internamente para a lista em árvore das `Page` suportadas por ele.

## Guia de Início Rápido

### 1. Defina suas Rotas

```dart
import 'package:flutter_full_router/flutter_full_router.dart';

final routes = <FFRRouteDefinition>[
  FFRRouteDefinition(
    id: '01SPL',
    path: '/',
    openFlow: FFROpenFlow.preLogin,
    builder: (context, pathParams, queryParams) => const SplashScreen(),
  ),
  FFRRouteDefinition(
    id: '02POS',
    path: '/post/{id}',
    pathParams: {'id': r'[0-9]+'}, // Regra da RegEx aplicada para a constraint
    openFlow: FFROpenFlow.postLogin,
    builder: (context, pathParams, queryParams) => PostScreen(id: pathParams['id']!),
  ),
  // Rota Action: executa a funcão associada ao invés de buscar e montar as instâncias de Widget de renderização para a UI.
  FFRRouteDefinition(
    id: '03LGO',
    path: '/logout',
    routeType: FFRRouteType.action,
    openFlow: FFROpenFlow.postLogin,
    action: (pathParams, queryParams) {
      AuthService.logout();
      FFRNavigator.I.pushReplacementNamed('/login');
    },
  ),
];
```

### 2. Configure a API do Navigator Central

Simplesmente recrie o objeto como única classe/módulo para dar start e assentar devidamente seu próprio local nativo em cena do método do Singleton do `FFRNavigator.I`.

```dart
final parser = FFRRouteParser(routes);

FFRNavigator(
  parser: parser,
  initialRoute: '/',
  notFoundRoute: '/404',
  observers: [FFRRouteLogger()],
  guard: (match) {
    if (match.route.openFlow == FFROpenFlow.postLogin && !isLoggedIn) {
      return '/login'; // Intercepta pro endpoint ideal e redireciona com tudo pronto à exilíbri-lo!
    }
    return null;
  },
);
```

### 3. Integração total ligada aos motores unificados de UI global na função base de seu `MaterialApp`

Crie seus delegates como propriedades assincronamente estocadas as definindo sem rodeios no momento oportuno dentro e de modo direto com ao instanciá-los como argumentos explícitos aos `MaterialApp` via `.router()`.

```dart
class _MyAppState extends State<MyApp> {
  late final FFRRouterDelegate delegate;
  late final FFRRouteInformationParser infoParser;

  @override
  void initState() {
    super.initState();
    // Repassa global state com FFRNavigator
    delegate = FFRRouterDelegate(FFRNavigator.I);
    infoParser = const FFRRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: delegate,
      routeInformationParser: infoParser,
      title: 'My FFR App',
    );
  }
}
```

### 4. Chamadas! (Navegação livre pelo ecossistema do app)

```dart
// Empilhe a instrução como URL ordinariamente.
FFRNavigator.I.pushNamed('/settings');

// Reinicializador total em uma via e apagamento em todas instâncias empilhadas na hierarquia do App
FFRNavigator.I.pushReplacementNamed('/login');

// Push de envio prático que contem chaves customizadas pré montadas ativas
FFRNavigator.I.pushNamed(
  '/user/{username}',
  pathParams: {'username': 'johndoe'},
  queryParams: {'sort': 'asc'}
);

// Acione nativamente a função a um sistema modular sem necessidade que se dependencie
FFRNavigator.I.pushNamed('/logout');
```

---

## Modulo de Assinalação de Rotas Flexível & Sem Reinicializações (Live & Dynamic Registration)

Rotas de Interface de Navegação central formam em tempo de execução nativa do app toda base na matriz a fim de expor a UI em módulos/plugins e se subistuir dinamicamente as flags para compor micro-fronteiras das funções modulares e suas propriedades e extensões sob demanda (arquiteturas lazy format/injection/modulacao)

### Registre suas unificadas UI Rotines Individualmente

```dart
FFRNavigator.I.addRoute(FFRRouteDefinition(
  id: '99NEW',
  path: '/new-feature',
  openFlow: FFROpenFlow.postLogin,
  builder: (context, p, q) => const NewFeatureScreen(),
));

// Imediatamente será englobada para o App chamar de prontidão :
FFRNavigator.I.pushNamed('/new-feature');
```

### Atribuindo várias e englobando por completo aos seus endpoints rotinas do app.

```dart
FFRNavigator.I.addRoutes([
  FFRRouteDefinition(
    id: '10PRF',
    path: '/profile',
    builder: (context, p, q) => const ProfileScreen(),
  ),
  FFRRouteDefinition(
    id: '11SET',
    path: '/settings',
    builder: (context, p, q) => const SettingsScreen(),
  ),
]);
```

### Desapontando rotinas

```dart
// Simplesmente evoque sua unlist e delete da navegação sem ser visto novamente - rota cessa operante!
FFRNavigator.I.removeRoute('99NEW');
```

> **Atenção:** `addRoute` irá subescrever com segurança instâncias que já com sua matricula de preexistência forem expostos ao serem declarados/enviados. Escutadores são avisamente declarados nos subníveis das ramificações das suas lógicas internas sempre para transparecer as instâncias ativas a matriz de modo em sync nativo a qualquer eventual mudança do quadro unificado global das rotas e na via-crucis modular atual no delegate do Router FFR ao decorrer da operatividade `FFRRouterDelegate`.

---

Examine detalhadamente os cenários internos nativamente demonstrados em profundos exemplos pelo pacote FFR acessando `example/`. Nele contempla uma demostração minunciosamente trabalhada da unificação das chamadas e da central assíncrona base intercepcões à telas sobreposta.
