import { useState } from 'react'
import {
  AppShell,
  Button,
  Card,
  Badge,
  Group,
  Text,
  Stack,
  Title,
  Container,
  Paper,
  Grid,
  ThemeIcon,
  useMantineColorScheme,
  ActionIcon
} from '@mantine/core'
import { notifications } from '@mantine/notifications'
import {
  IconCheck,
  IconClock,
  IconBolt,
  IconSun,
  IconMoon
} from '@tabler/icons-react'

function App() {
  const [taskCount, setTaskCount] = useState(0)
  const { colorScheme, toggleColorScheme } = useMantineColorScheme()

  const handleCreateTask = () => {
    const newCount = taskCount + 1
    setTaskCount(newCount)

    notifications.show({
      title: 'Task Created',
      message: `Task #${newCount} has been created successfully!`,
      color: 'teal',
      icon: <IconCheck size={18} />,
    })
  }

  return (
    <AppShell
      header={{ height: 60 }}
      padding="md"
    >
      <AppShell.Header>
        <Group h="100%" px="md" justify="space-between">
          <Group>
            <ThemeIcon size="lg" variant="gradient" gradient={{ from: 'blue', to: 'cyan' }}>
              <IconBolt size={20} />
            </ThemeIcon>
            <Title order={3}>Real-time Task Management</Title>
          </Group>
          <ActionIcon
            variant="default"
            onClick={() => toggleColorScheme()}
            size="lg"
          >
            {colorScheme === 'dark' ? <IconSun size={18} /> : <IconMoon size={18} />}
          </ActionIcon>
        </Group>
      </AppShell.Header>

      <AppShell.Main>
        <Container size="lg">
          <Stack gap="xl">
            <Paper p="xl" radius="md" withBorder>
              <Stack gap="md">
                <Title order={2}>Welcome to Your Task Hub</Title>
                <Text c="dimmed">
                  Built with React 19, Vite, and Mantine. Ready for SignalR real-time updates!
                </Text>
                <Group>
                  <Badge color="blue" variant="light">React 19</Badge>
                  <Badge color="cyan" variant="light">Vite HMR</Badge>
                  <Badge color="grape" variant="light">Mantine UI</Badge>
                  <Badge color="green" variant="light">TypeScript</Badge>
                </Group>
              </Stack>
            </Paper>

            <Grid>
              <Grid.Col span={{ base: 12, md: 4 }}>
                <Card shadow="sm" padding="lg" radius="md" withBorder>
                  <Stack gap="sm">
                    <ThemeIcon size="xl" radius="md" variant="gradient" gradient={{ from: 'blue', to: 'cyan' }}>
                      <IconClock size={24} />
                    </ThemeIcon>
                    <Text fw={500}>Pending Tasks</Text>
                    <Title order={2}>{taskCount}</Title>
                    <Text size="sm" c="dimmed">
                      Click below to test HMR and notifications
                    </Text>
                  </Stack>
                </Card>
              </Grid.Col>

              <Grid.Col span={{ base: 12, md: 4 }}>
                <Card shadow="sm" padding="lg" radius="md" withBorder>
                  <Stack gap="sm">
                    <ThemeIcon size="xl" radius="md" variant="gradient" gradient={{ from: 'teal', to: 'lime' }}>
                      <IconCheck size={24} />
                    </ThemeIcon>
                    <Text fw={500}>Completed</Text>
                    <Title order={2}>0</Title>
                    <Text size="sm" c="dimmed">
                      Ready for SignalR integration
                    </Text>
                  </Stack>
                </Card>
              </Grid.Col>

              <Grid.Col span={{ base: 12, md: 4 }}>
                <Card shadow="sm" padding="lg" radius="md" withBorder>
                  <Stack gap="sm">
                    <ThemeIcon size="xl" radius="md" variant="gradient" gradient={{ from: 'orange', to: 'red' }}>
                      <IconBolt size={24} />
                    </ThemeIcon>
                    <Text fw={500}>Real-time Events</Text>
                    <Title order={2}>Ready</Title>
                    <Text size="sm" c="dimmed">
                      Kafka, RabbitMQ, Redis ready
                    </Text>
                  </Stack>
                </Card>
              </Grid.Col>
            </Grid>

            <Paper p="lg" radius="md" withBorder>
              <Stack gap="md" align="center">
                <Title order={3}>Test HMR & Notifications</Title>
                <Button
                  size="lg"
                  variant="gradient"
                  gradient={{ from: 'blue', to: 'cyan' }}
                  onClick={handleCreateTask}
                >
                  Create New Task
                </Button>
                <Text size="sm" c="dimmed">
                  Edit <code>src/App.tsx</code> and save to test Hot Module Replacement
                </Text>
              </Stack>
            </Paper>
          </Stack>
        </Container>
      </AppShell.Main>
    </AppShell>
  )
}

export default App
