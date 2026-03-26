<script setup lang="ts">
import { Motion } from 'motion-v'
import type { TeacherMentor } from '~/components/TeacherCard.vue'

type MentorWithFeatured = TeacherMentor & { featured?: boolean }

const teacherBlobs = ['amoeba_cross', 'tri_lobe', 'star_puffy', 'slug_floating'] as const

const getBlobForTeacher = (index: number): (typeof teacherBlobs)[number] => {
  return teacherBlobs[index % teacherBlobs.length]!
}

const { data: page } = await useAsyncData('teachers-directory', () => queryCollection('index').first())
if (!page.value) {
  throw createError({
    statusCode: 404,
    statusMessage: 'Page not found',
    fatal: true
  })
}

const mentors = computed(() => (page.value!.teachers.mentors ?? []) as MentorWithFeatured[])

const featuredMentor = computed(() => mentors.value.find(m => m.featured) ?? null)

const gridSourceMentors = computed(() => {
  if (mentors.value.some(m => m.featured)) {
    return mentors.value.filter(m => !m.featured)
  }
  return mentors.value
})

const route = useRoute()

function queryParamString(q: unknown): string {
  if (typeof q === 'string') return q
  if (Array.isArray(q) && typeof q[0] === 'string') return q[0]
  return ''
}

const searchQuery = ref(queryParamString(route.query.q))
const selectedSubject = ref<string | null>(
  queryParamString(route.query.subject) || null
)

watch(searchQuery, (newVal) => {
  if (newVal) {
    navigateTo({ path: '/teachers', query: { q: newVal } }, { replace: true })
  } else {
    navigateTo({ path: '/teachers' }, { replace: true })
  }
})

watch(selectedSubject, (newVal) => {
  if (newVal) {
    navigateTo({ path: '/teachers', query: { subject: newVal } }, { replace: true })
  } else {
    navigateTo({ path: '/teachers' }, { replace: true })
  }
})

const allSpecialties = computed(() => {
  const set = new Set<string>()
  for (const m of mentors.value) {
    for (const s of m.specialties) {
      set.add(s)
    }
  }
  return [...set].sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base' }))
})

function mentorMatchesSearch(m: MentorWithFeatured, q: string): boolean {
  if (!q.trim()) return true
  const n = q.trim().toLowerCase()
  const hay = [m.name, m.role, m.description, ...m.specialties].join(' ').toLowerCase()
  return hay.includes(n)
}

function mentorMatchesSubject(m: MentorWithFeatured, sub: string | null): boolean {
  if (!sub) return true
  return m.specialties.includes(sub)
}

const filteredGridMentors = computed(() =>
  gridSourceMentors.value.filter(
    m => mentorMatchesSearch(m, searchQuery.value) && mentorMatchesSubject(m, selectedSubject.value)
  )
)

function mentorStableIndex(m: MentorWithFeatured): number {
  return mentors.value.findIndex(x => x.name === m.name && x.role === m.role)
}

function toggleSubject(s: string): void {
  selectedSubject.value = selectedSubject.value === s ? null : s
}

function resetSubjectFilter(): void {
  selectedSubject.value = null
  if (!queryParamString(route.query.subject)) return
  const rest = { ...route.query } as Record<string, unknown>
  delete rest.subject
  const nextQuery = Object.fromEntries(
    Object.entries(rest).filter(([, v]) => v !== undefined && v !== null && v !== '')
  ) as Record<string, string>
  if (Object.keys(nextQuery).length === 0) {
    void navigateTo({ path: '/teachers' }, { replace: true })
  } else {
    void navigateTo({ path: '/teachers', query: nextQuery }, { replace: true })
  }
}

const featuredBlob = computed(() => {
  const f = featuredMentor.value
  if (!f) return teacherBlobs[0]!
  return getBlobForTeacher(mentorStableIndex(f))
})

useSeoMeta({
  title: 'Find Your Mentor',
  description: page.value.teachers.description
})
</script>

<template>
  <div
    v-if="page"
    data-testid="teachers-page"
    class="min-h-screen pb-20 lg:pb-28 pt-24 sm:pt-28"
  >
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <header class="text-center mb-14 lg:mb-16">
        <Motion
          :initial="{ opacity: 0, y: 20 }"
          :animate="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, ease: 'easeOut' }"
        >
          <h1
            data-testid="teachers-page-title"
            class="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4 font-heading"
          >
            Find Your Mentor
          </h1>
          <div
            class="mx-auto h-1 w-24 sm:w-32 rounded-full bg-linear-to-r from-primary-500 to-red-500 opacity-90"
            aria-hidden="true"
          />
        </Motion>
        <Motion
          :initial="{ opacity: 0, y: 16 }"
          :animate="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.45, ease: 'easeOut', delay: 0.08 }"
        >
          <p class="mt-6 text-lg text-[#CCCCCC] max-w-2xl mx-auto">
            {{ page.teachers.description }}
          </p>
        </Motion>
      </header>

      <div class="flex flex-col lg:flex-row gap-10 lg:gap-12 items-start">
        <!-- Sidebar: client-only so filter actions bind reliably after hydration -->
        <ClientOnly>
          <template #fallback>
            <div
              class="w-full lg:w-64 shrink-0 space-y-8"
              aria-hidden="true"
            />
          </template>
          <aside
            class="w-full lg:w-64 shrink-0 space-y-8 lg:sticky lg:top-28"
            aria-label="Filter teachers"
          >
            <div>
              <label
                for="teachers-search-input"
                class="block text-sm font-medium text-white mb-2"
              >Search</label>
              <div
                data-testid="teachers-search"
                class="relative w-full rounded-lg glass border border-white/10 focus-within:ring-2 focus-within:ring-primary-500/30 focus-within:border-primary-500/30 transition-all"
              >
                <UIcon
                  name="i-lucide-search"
                  class="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-gray-500 pointer-events-none"
                />
                <input
                  id="teachers-search-input"
                  v-model="searchQuery"
                  type="search"
                  autocomplete="off"
                  placeholder="Name, subject, or keyword"
                  class="w-full bg-transparent text-white placeholder:text-gray-500 text-sm py-2.5 pl-10 pr-3 rounded-lg outline-none"
                >
              </div>
            </div>

            <div>
              <p class="text-sm font-medium text-white mb-3">
                Subjects
              </p>
              <div class="flex flex-col gap-2 max-h-[min(70vh,32rem)] overflow-y-auto pr-1">
                <button
                  type="button"
                  data-testid="teachers-subject-clear"
                  class="text-left text-sm px-3 py-2 rounded-lg border transition-colors shrink-0"
                  :class="selectedSubject === null
                    ? 'bg-white/10 border-primary-500/40 text-white'
                    : 'bg-white/5 border-white/10 text-gray-300 hover:bg-white/10'"
                  @click="resetSubjectFilter"
                >
                  All subjects
                </button>
                <button
                  v-for="specialty in allSpecialties"
                  :key="specialty"
                  type="button"
                  class="text-left text-sm px-3 py-2 rounded-lg border transition-colors shrink-0"
                  :class="selectedSubject === specialty
                    ? 'bg-primary-500/15 border-primary-500/30 text-primary-200'
                    : 'bg-transparent border-white/10 text-gray-300 hover:bg-white/5'"
                  @click="toggleSubject(specialty)"
                >
                  {{ specialty }}
                </button>
              </div>
            </div>
          </aside>
        </ClientOnly>

        <!-- Main -->
        <div class="flex-1 min-w-0 space-y-10 w-full">
          <section
            v-if="featuredMentor"
            data-testid="teachers-featured"
            class="relative rounded-3xl glass border border-white/10 overflow-hidden p-6 sm:p-8 lg:p-10"
          >
            <div
              class="absolute inset-0 rounded-3xl border border-white/5 pointer-events-none"
            />
            <div class="relative z-10 flex flex-col lg:flex-row gap-8 lg:gap-10 items-center lg:items-stretch">
              <div class="relative shrink-0 flex justify-center lg:justify-start">
                <div class="absolute w-64 h-64 flex items-center justify-center pointer-events-none opacity-90">
                  <AppBlob
                    :name="featuredBlob"
                    class="w-full h-full"
                  />
                </div>
                <div class="relative z-10 w-40 h-40 sm:w-44 sm:h-44 rounded-2xl p-1 bg-white/10 ring-1 ring-white/20 shadow-2xl">
                  <div class="w-full h-full rounded-xl overflow-hidden border border-white/10 bg-gray-900">
                    <img
                      :src="featuredMentor.avatar.src"
                      :alt="featuredMentor.name"
                      class="w-full h-full object-cover"
                    >
                  </div>
                </div>
              </div>
              <div class="flex-1 text-center lg:text-left flex flex-col justify-center">
                <p class="text-primary-400 text-sm font-semibold uppercase tracking-wide mb-2">
                  Featured Teacher
                </p>
                <h2
                  data-testid="teachers-featured-name"
                  class="text-2xl sm:text-3xl font-bold text-white font-heading mb-2"
                >
                  {{ featuredMentor.name }}
                </h2>
                <p class="text-primary-300 text-sm font-medium mb-4">
                  {{ featuredMentor.role }}
                </p>
                <p class="text-gray-400 text-sm sm:text-base leading-relaxed mb-6">
                  {{ featuredMentor.description }}
                </p>
                <div class="flex flex-wrap gap-3 justify-center lg:justify-start">
                  <UButton
                    color="primary"
                    label="Book a session"
                    data-testid="teachers-featured-cta-primary"
                  />
                  <UButton
                    color="neutral"
                    variant="outline"
                    label="View specialties"
                    data-testid="teachers-featured-cta-secondary"
                  />
                </div>
              </div>
            </div>
          </section>

          <section aria-label="All teachers">
            <div
              v-if="filteredGridMentors.length === 0"
              class="text-center py-16 text-gray-400"
            >
              No teachers match your filters. Try clearing search or subjects.
            </div>
            <div
              v-else
              class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
            >
              <TeacherCard
                v-for="(mentor, idx) in filteredGridMentors"
                :key="`${mentor.name}-${mentor.role}`"
                :mentor
                :blob-name="getBlobForTeacher(mentorStableIndex(mentor))"
                :index="idx"
                :test-id="`teachers-grid-card-${idx}`"
              />
            </div>
          </section>
        </div>
      </div>
    </div>
  </div>
</template>
