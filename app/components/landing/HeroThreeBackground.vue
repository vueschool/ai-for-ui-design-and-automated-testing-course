<script setup lang="ts">
// Do NOT USE THIS COMPONENT. It's not working and is not needed.
import * as THREE from 'three'
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js'
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js'

// Canvas ref
const canvasRef = ref<HTMLCanvasElement>()
const containerRef = ref<HTMLDivElement>()

// Mouse position (normalized -1 to 1)
const mouse = reactive({ x: 0, y: 0, targetX: 0, targetY: 0 })

// Blob configuration
interface BlobConfig {
  position: THREE.Vector3
  basePosition: THREE.Vector3
  scale: number
  speed: number
  phaseOffset: number
  color: THREE.Color
}

let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let composer: EffectComposer
const blobs: THREE.Mesh[] = []
let blobConfigs: BlobConfig[] = []
let animationId: number
let time = 0

// Theme colors matching the warm orange-red palette
const primaryColor = new THREE.Color('#F6512F')
const secondaryColor = new THREE.Color('#E71407')
const tertiaryColor = new THREE.Color('#FF8269')

// Shader for gradient blobs with glow
const blobVertexShader = `
  varying vec3 vNormal;
  varying vec3 vPosition;
  varying vec2 vUv;

  uniform float uTime;
  uniform float uMorphStrength;
  uniform vec3 uMouseInfluence;

  // Simplex noise functions
  vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
  vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
  vec4 permute(vec4 x) { return mod289(((x*34.0)+1.0)*x); }
  vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

  float snoise(vec3 v) {
    const vec2 C = vec2(1.0/6.0, 1.0/3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    i = mod289(i);
    vec4 p = permute(permute(permute(
      i.z + vec4(0.0, i1.z, i2.z, 1.0))
      + i.y + vec4(0.0, i1.y, i2.y, 1.0))
      + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857;
    vec3 ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;

    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);

    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));
  }

  void main() {
    vUv = uv;
    vNormal = normalize(normalMatrix * normal);

    // Organic deformation using noise
    float noise1 = snoise(position * 0.8 + uTime * 0.3) * uMorphStrength;
    float noise2 = snoise(position * 1.2 + uTime * 0.2 + 100.0) * uMorphStrength * 0.5;

    // Mouse influence - blobs react to cursor
    vec3 worldPos = (modelMatrix * vec4(position, 1.0)).xyz;
    float mouseDistance = length(worldPos.xy - uMouseInfluence.xy);
    float mouseEffect = smoothstep(3.0, 0.0, mouseDistance) * uMouseInfluence.z * 0.3;

    vec3 displaced = position + normal * (noise1 + noise2 + mouseEffect);

    vPosition = displaced;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(displaced, 1.0);
  }
`

const blobFragmentShader = `
  varying vec3 vNormal;
  varying vec3 vPosition;
  varying vec2 vUv;

  uniform vec3 uColor1;
  uniform vec3 uColor2;
  uniform float uTime;
  uniform vec3 uLightPosition;

  void main() {
    // Fresnel effect for edge glow
    vec3 viewDirection = normalize(cameraPosition - vPosition);
    float fresnel = pow(1.0 - max(dot(viewDirection, vNormal), 0.0), 2.5);

    // Gradient based on position and normal
    float gradientFactor = (vNormal.y + 1.0) * 0.5;
    gradientFactor += sin(vUv.x * 3.14159 + uTime * 0.5) * 0.1;

    vec3 baseColor = mix(uColor1, uColor2, gradientFactor);

    // Simple lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    float diff = max(dot(vNormal, lightDir), 0.0);
    float ambient = 0.4;

    // Specular highlight
    vec3 reflectDir = reflect(-lightDir, vNormal);
    float spec = pow(max(dot(viewDirection, reflectDir), 0.0), 32.0) * 0.5;

    // Combine everything
    vec3 finalColor = baseColor * (ambient + diff * 0.6) + vec3(1.0, 0.9, 0.8) * spec;

    // Add fresnel glow
    finalColor += baseColor * fresnel * 0.8;

    // Soft edge fade
    float edgeFade = smoothstep(0.0, 0.3, 1.0 - fresnel * 0.5);

    gl_FragColor = vec4(finalColor, edgeFade * 0.95);
  }
`

const createBlob = (config: BlobConfig): THREE.Mesh => {
  const geometry = new THREE.IcosahedronGeometry(1, 5)

  const material = new THREE.ShaderMaterial({
    vertexShader: blobVertexShader,
    fragmentShader: blobFragmentShader,
    uniforms: {
      uTime: { value: 0 },
      uMorphStrength: { value: 0.15 },
      uMouseInfluence: { value: new THREE.Vector3(0, 0, 0) },
      uColor1: { value: config.color.clone() },
      uColor2: { value: secondaryColor.clone() },
      uLightPosition: { value: new THREE.Vector3(5, 5, 10) }
    },
    transparent: true,
    side: THREE.DoubleSide,
    depthWrite: false
  })

  const mesh = new THREE.Mesh(geometry, material)
  mesh.position.copy(config.position)
  mesh.scale.setScalar(config.scale)

  return mesh
}

const initScene = () => {
  if (!canvasRef.value || !containerRef.value) return

  const { width, height } = containerRef.value.getBoundingClientRect()

  // Scene setup
  scene = new THREE.Scene()
  scene.background = new THREE.Color('#121619')

  // Camera
  camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 100)
  camera.position.z = 8

  // Renderer
  renderer = new THREE.WebGLRenderer({
    canvas: canvasRef.value,
    antialias: true,
    alpha: true
  })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.2

  // Post-processing for bloom/glow
  composer = new EffectComposer(renderer)
  const renderPass = new RenderPass(scene, camera)
  composer.addPass(renderPass)

  const bloomPass = new UnrealBloomPass(
    new THREE.Vector2(width, height),
    0.8, // strength
    0.4, // radius
    0.85 // threshold
  )
  composer.addPass(bloomPass)

  // Create blob configurations - positioned like the reference images
  blobConfigs = [
    // Top-left cluster (like blob-top-left.png)
    {
      position: new THREE.Vector3(-4.5, 3, -2),
      basePosition: new THREE.Vector3(-4.5, 3, -2),
      scale: 2.8,
      speed: 0.3,
      phaseOffset: 0,
      color: primaryColor.clone()
    },
    {
      position: new THREE.Vector3(-3.2, 1.5, -1),
      basePosition: new THREE.Vector3(-3.2, 1.5, -1),
      scale: 1.8,
      speed: 0.4,
      phaseOffset: Math.PI * 0.5,
      color: secondaryColor.clone()
    },
    {
      position: new THREE.Vector3(-2.5, 2.8, -0.5),
      basePosition: new THREE.Vector3(-2.5, 2.8, -0.5),
      scale: 1.4,
      speed: 0.35,
      phaseOffset: Math.PI,
      color: tertiaryColor.clone()
    },
    // Top-right cluster (like blob-top-right.png)
    {
      position: new THREE.Vector3(4.5, 2.5, -2),
      basePosition: new THREE.Vector3(4.5, 2.5, -2),
      scale: 2.5,
      speed: 0.25,
      phaseOffset: Math.PI * 0.25,
      color: primaryColor.clone().lerp(secondaryColor, 0.3)
    },
    {
      position: new THREE.Vector3(3.2, 1, -1),
      basePosition: new THREE.Vector3(3.2, 1, -1),
      scale: 1.6,
      speed: 0.45,
      phaseOffset: Math.PI * 0.75,
      color: secondaryColor.clone()
    },
    // Bottom accent blobs
    {
      position: new THREE.Vector3(-1, -3, -3),
      basePosition: new THREE.Vector3(-1, -3, -3),
      scale: 1.2,
      speed: 0.5,
      phaseOffset: Math.PI * 1.5,
      color: tertiaryColor.clone()
    },
    {
      position: new THREE.Vector3(2, -2.5, -2.5),
      basePosition: new THREE.Vector3(2, -2.5, -2.5),
      scale: 1.0,
      speed: 0.4,
      phaseOffset: Math.PI * 0.3,
      color: primaryColor.clone()
    }
  ]

  // Create blobs
  blobConfigs.forEach((config) => {
    const blob = createBlob(config)
    blobs.push(blob)
    scene.add(blob)
  })

  // Ambient light
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.5)
  scene.add(ambientLight)

  // Point lights for dramatic effect
  const pointLight1 = new THREE.PointLight('#FF6B4A', 2, 20)
  pointLight1.position.set(5, 5, 5)
  scene.add(pointLight1)

  const pointLight2 = new THREE.PointLight('#E71407', 1.5, 15)
  pointLight2.position.set(-5, -3, 3)
  scene.add(pointLight2)
}

const animate = () => {
  time += 0.016 // ~60fps

  // Smooth mouse interpolation
  mouse.x += (mouse.targetX - mouse.x) * 0.05
  mouse.y += (mouse.targetY - mouse.y) * 0.05

  // Update blobs
  blobs.forEach((blob, index) => {
    const config = blobConfigs[index]
    const material = blob.material as THREE.ShaderMaterial

    // Update shader time
    material.uniforms.uTime.value = time

    // Update mouse influence
    material.uniforms.uMouseInfluence.value.set(
      mouse.x * 5,
      mouse.y * 3,
      1.0
    )

    // Floating animation
    const floatX = Math.sin(time * config.speed + config.phaseOffset) * 0.3
    const floatY = Math.cos(time * config.speed * 0.7 + config.phaseOffset) * 0.2
    const floatZ = Math.sin(time * config.speed * 0.5 + config.phaseOffset) * 0.1

    blob.position.x = config.basePosition.x + floatX + mouse.x * 0.5
    blob.position.y = config.basePosition.y + floatY + mouse.y * 0.3
    blob.position.z = config.basePosition.z + floatZ

    // Subtle rotation
    blob.rotation.x = Math.sin(time * 0.2 + config.phaseOffset) * 0.1
    blob.rotation.y = Math.cos(time * 0.15 + config.phaseOffset) * 0.1

    // Subtle scale pulsing
    const scalePulse = 1 + Math.sin(time * config.speed * 2 + config.phaseOffset) * 0.05
    blob.scale.setScalar(config.scale * scalePulse)
  })

  // Render
  if (composer) {
    composer.render()
  }

  animationId = requestAnimationFrame(animate)
}

const onMouseMove = (event: MouseEvent) => {
  if (!containerRef.value) return

  const rect = containerRef.value.getBoundingClientRect()
  mouse.targetX = ((event.clientX - rect.left) / rect.width) * 2 - 1
  mouse.targetY = -((event.clientY - rect.top) / rect.height) * 2 + 1
}

const onTouchMove = (event: TouchEvent) => {
  if (!containerRef.value || !event.touches[0]) return

  const rect = containerRef.value.getBoundingClientRect()
  const touch = event.touches[0]
  mouse.targetX = ((touch.clientX - rect.left) / rect.width) * 2 - 1
  mouse.targetY = -((touch.clientY - rect.top) / rect.height) * 2 + 1
}

const onResize = () => {
  if (!containerRef.value || !camera || !renderer || !composer) return

  const { width, height } = containerRef.value.getBoundingClientRect()

  camera.aspect = width / height
  camera.updateProjectionMatrix()

  renderer.setSize(width, height)
  composer.setSize(width, height)
}

onMounted(() => {
  initScene()
  animate()

  window.addEventListener('mousemove', onMouseMove)
  window.addEventListener('touchmove', onTouchMove)
  window.addEventListener('resize', onResize)
})

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }

  window.removeEventListener('mousemove', onMouseMove)
  window.removeEventListener('touchmove', onTouchMove)
  window.removeEventListener('resize', onResize)

  // Cleanup Three.js resources
  blobs.forEach((blob) => {
    blob.geometry.dispose()
    if (blob.material instanceof THREE.Material) {
      blob.material.dispose()
    }
  })

  if (renderer) {
    renderer.dispose()
  }
})
</script>

<template>
  <div
    ref="containerRef"
    class="absolute inset-0 overflow-hidden"
  >
    <Motion
      :initial="{ opacity: 0 }"
      :animate="{ opacity: 1 }"
      :transition="{ duration: 1.5, ease: 'easeOut' }"
    >
      <canvas
        ref="canvasRef"
        class="absolute inset-0 w-full h-full"
      />
    </Motion>

    <!-- Gradient overlays for depth -->
    <div class="absolute inset-0 pointer-events-none">
      <!-- Top fade -->
      <div class="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-[#121619] to-transparent" />

      <!-- Bottom fade -->
      <div class="absolute bottom-0 left-0 right-0 h-48 lg:h-64 bg-gradient-to-t from-[#121619] via-[#121619]/80 to-transparent" />

      <!-- Subtle vignette -->
      <div class="absolute inset-0 bg-radial-[ellipse_at_center] from-transparent via-transparent to-[#121619]/40" />
    </div>
  </div>
</template>
