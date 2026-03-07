# Flutter Full Router (FFR)

Un potente motor de navegación sin dependencias, construido desde cero para Flutter utilizando la API nativa de `Router`. Olvídate de complejas bibliotecas de enrutamiento de terceros: FFR te brinda control total sobre tu pila de navegación, extracción de parámetros de URL, intercepción de autenticación mediante _guards_, enrutamiento nombrado dinámico, superposiciones personalizadas para modales y hojas inferiores (bottom sheets), **registro de rutas en tiempo de ejecución** y **rutas de acción**.

## ¿Por qué elegir FFR?

La API de Navigator 2.0 (Router) de Flutter es conocida por ser sumamente verbosa y algo compleja. FFR encapsula esta complejidad dentro de un motor de estado limpio y reactivo (`FFRNavigator`) que emula la simplicidad de la navegación basada en URL tradicional de Flutter, dotada de características avanzadas para entornos reales de producción de aplicaciones de todo tipo.

**Características Principales:**

- **Cero Dependencias:** Escrito completamente sobre Dart/Flutter base. Se integra sencillamente apuntándolo director al property `MaterialApp.router`.
- **Acceso Exclusivo Singleton:** Dispone su llamado general bajo su acceso a `FFRNavigator.I` libremente sin depender directamente en pase de funciones complejas u objetos!
- **Gestor Dinámico de Propiedades de URLs:** Las utilidades enrrolladas en `FFRRouteParser` pre asimila nativas descripciones formales y extraen `/{id}` u `/{username}` y transforma dichos paths en objectos de lectura del map hacia el llamado widget al interior de los constructores.
- **Tipos de Rutas Personalizados:** Inserción simple de pantallas de alto calibre en su uso completo, asi en su nativo formato o ya con `Dialog`s y un robusto abanico extra de variaciones incluyendo soporte a `ModalBottomSheet`s con simples rutas apuntadas a una URL base de la acción asignada y requerida. Con componentes construidos e internalizados se asegura poder sobrellevar procesos en stack para dar abastro correcto al botón regresar sin desfasajes en el historial interno/SO.
- **Acciones y Tareas Ejecutables (Action Routes):** Simplifique lógica estructurándola con formatos (`FFRRouteType.action`). Su navegabilidad al llamado resulta en accionables basados e impulsada a llamadas internas para accionar el entorno en servicios tales como: Salida (LogOuts), Calls o Eventos base API interrelacionados con asombrosa claridad omitiendo transiciones intermitentes no esperadas hacia apilados inoportunos sobre páginas nuevas sin propósitos.
- **Interceptores Base Seguros y Escudos:** Proporciona un soporte modular y controlada bajo capas al componente en forma general y concisa `FFRRouteGuard`. Posibilitada para re-conducir y controlar usuarios hacia otras trayectorias para ser intersecadas anticipadamente en tiempo oportuno sin iniciar constructores previos de base a los Widgets. Ejemplo la intercepción sin re direccionar previamente fuera del esquema normal a fin de denegar hacia un log in.
- **Gestión Histórica en Navegaciones:** Posibilidad de interconectar cualquier sub oyente al historial sin cortes base los escuchadores del `ChangeNotifier` expondiendo historial robusto sin percances a inspección completa sobre la propiedad interna a consultar bajo cualquier lugar: `FFRNavigator.I.history`.
- **Visores de Depurado Estricto:** Fiel e intencionado observador oficial enfocado asimilado a formato Flutter bajo en integraciones a sus properties de `NavigatorObserver`, contando su version de visor orgánico `FFRRouteLogger` asegurando visualización y debug de manera inmaculada!
- **Declaración Asíncrona Dinámica:** Integrado un sistema en la base que en tiempo libre logra añadir sin deméritos a toda interface interna central para compilar y cargar un conjunto final bajo bandera, interconexión remota y en desmedidas aplicaciones como Plugins lazy cargadas sin redibujados (Rebuilds completos), y sub sistemas dinámicos!

## Arquitectura general

División del framework estructuradas sobre lógicas de sus bases de la siguiente rama.

1. **Estructura Declarativa Base, Los cimientos (`FFRRouteDefinition`)**:
   Se instancian objetos alusivos que exponen e interceptará en el transitar la asignación final al recurso (`/home`), qué render a de utilizarse a su favor (`fullPage`, `dialog`, `bottomSheet`, y ahora a su vez `action`), determinadores de limitación temporal al usuario y estado (`FFROpenFlow.postLogin`), en combinación total adjunto a constructores a desplegar `builder` (si el layout base requiere instanciar las interfaces nativas del componente a la aplicación (Widget)) o en base las lógicas y derivantes a accionar internamente se evoca adjunto a (`action`) para no emitir y evitar un layout de cara del usuario (UI).

2. **Receptores / Moduladores y Procesador Analítico (`FFRRouteParser`)**:
   En sintonía toma el cargo y transforma los eslabones como literales en strings con componentes `/post/123?ref=social` contrastándolo e igualando sus referencias inscritas centralizadas y declarativas. Así en su extracción las variables del eslabon `id=123` en forma mapeada son insertas y dictadas formalmente adentro del `pathParams` al igual así `ref=social` interiorizando a la llave y valor sobre `queryParams`, derivando e igualando las entregas con el valor principal retornado `FFRRouteMatch`. Entorno que asume todo a los aditivos a tiempo libre a desinstalar desde la tabla y registros que posee al interno su procesamiento.

3. **Sistema y Gestor Inteligente , El Enroque Complejo (`FFRNavigator`)**:
   El corazón central. Las llamadas son evocadas sencillamente mediante `FFRNavigator.I.pushNamed('/route')` lo cual levanta una flag/señal la instrucción base al receptor (parser) previamente mencionado. Una ves homologado se pasa al filtro previo en validaciones e interceptores registrados **Guard**. De dar la luz verde el gestor modificará finalmente `stack` - actualizando historiales de trazas enviándolo mediante el gestor a ser escuchado internamente y al render si no está definido el tipo action lo que terminará sólo como funciones terminadas internamente.
   - **Historial Nativo **: Disponible con seguridad e instantaneo con acceso `FFRNavigator.I.history`. Debido a su modelado este getter simula su base exacta exponiendo todas las páginas como se asienta desde la interface actual en vida.
   - **Administración en Tramos (Live) **: Agrega métodos directos sobre sí a administrar sin reconstruir el sistema, invocables a un simple comando `addRoute`, `addRoutes`, u por defecto y finalmente `removeRoute` modulando matrices libre.

4. **Delegatario Y Receptor Integral S.O/Aplicación (`FFRRouterDelegate` & `FFRRouteInformationParser`)**:
   Las piezas exactas para la sintonía a engranaje con su homólogo local `MaterialApp.router`. Funciona a base a interconectar la API e Información del receptor del S.O extraíendo componentes base de intenciones primarias y derivar el contexto al receptor el cual es delegado base una arquitectura que se modela nativamente una cascada a una lista sobre componentes internos Flutter base de Objetos (`Page`).

## Arranque Básico

### 1. Describiendo Trazabilidades de enrutado.

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
    pathParams: {'id': r'[0-9]+'}, // Regulaciones Re-Gex del param asignado.
    openFlow: FFROpenFlow.postLogin,
    builder: (context, pathParams, queryParams) => PostScreen(id: pathParams['id']!),
  ),
  // Acción Interna Ruteada : Realiza el flujo dictado subyacentemente para retornar resultados desasociando y descartando la acción a un  render real a Widget.
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

### 2. Seteos e Instanciables del gestor de Ruteado Único.

Declare su base configurativa del núcleo nativo!

```dart
final parser = FFRRouteParser(routes);

FFRNavigator(
  parser: parser,
  initialRoute: '/',
  notFoundRoute: '/404',
  observers: [FFRRouteLogger()],
  guard: (match) { // Interceptando de acuerdo alas descripciones pasadas del objeto en un instante.
    if (match.route.openFlow == FFROpenFlow.postLogin && !isLoggedIn) {
      return '/login'; // Reduccion  Interrumpe
    }
    return null;
  },
);
```

### 3. Conexiones hacia la cabecera `MaterialApp`

Arme a los enroscadores los datos que ha procesado previamente y apunte en conjunción como requerimientos que demanda internamente de las configuraciones y los delegatarios del layout del enrutador central de este para engranar todo `MaterialApp.router`.

```dart
class _MyAppState extends State<MyApp> {
  late final FFRRouterDelegate delegate;
  late final FFRRouteInformationParser infoParser;

  @override
  void initState() {
    super.initState();
    // Instancie pasandose globalmente del modelo a delegar en cabecera general!
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

### 4. Transicionando Libre al App . . . !

```dart
// Llamado ordinario sobre interface basico
FFRNavigator.I.pushNamed('/settings');

// Reinicializador total en una via y apagado de historia.
FFRNavigator.I.pushReplacementNamed('/login');

// Apoyos y mapeados con propiedades sobre llaves para la recepción (Argumentos del Componente a instanciar)
FFRNavigator.I.pushNamed(
  '/user/{username}',
  pathParams: {'username': 'johndoe'},
  queryParams: {'sort': 'asc'}
);

// Uso exclusivo del servicio Accionables sin renders .
FFRNavigator.I.pushNamed('/logout');
```

---

## Módulo Base Enrutados sin interrupciones o Restarts del App, "Dinámico " .

Propiedades adaptables y asíncronas para proveer bases sólidas re-acondicionando al app a lo previsto nativamente bajo bases modulares. Adiciones , Extracciones inter-conexas e ilimitadas para enrutar módulos y banderas "Features Flags o Plugin Systems!" sin de-meritos de renderizaciones internas ni deltas.

### Atendiendo las nuevas ramificaciones del árbol internamente .

```dart
FFRNavigator.I.addRoute(FFRRouteDefinition(
  id: '99NEW',
  path: '/new-feature',
  openFlow: FFROpenFlow.postLogin,
  builder: (context, p, q) => const NewFeatureScreen(),
));

// Integrable inmediato en operabilidad e interceptor y render base al app entero
FFRNavigator.I.pushNamed('/new-feature');
```

### Conjunto General para anidar listas en una adición múltiple para sus interfaces unificándose

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

### Intersección Limpia , remoción global

```dart
// Cancelando sub y descripciones enrutables dejandose irreconocibles local o en enlaces URL!
FFRNavigator.I.removeRoute('99NEW');
```

> **NOTA IMPORTANTE:** Al realizar un registro asíncrono , `addRoute` se emparejara para asimilar de modo contundente que no existe y si fuese a ver en la matriz algún choque de identidades del atributo enlazables el reemplazo sin demerito de su estado se provee . Escuchadores asimilaran para alertar el framework del update nativo dentro los deltas de reconstrucción delegatarios nativa interna del estado `FFRRouterDelegate` el cual se refresca libre !

---

En el paquete existe un componente funcional a demostración realizado y elaborado asentuando prácticas nativa al uso de un esquema general en `example/` . Una base del componente de inicio interconectada y operística usando Modales superposiciones interceptables e inyecciones de URL / Routing Models a la medida asíncrona real .
